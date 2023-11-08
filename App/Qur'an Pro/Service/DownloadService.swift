//  DownloadService.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import Foundation

let identifier: String = "group.com.bitbucket.benmoussa.islam.quranpro"
typealias CompleteHandlerBlock = () -> Void

enum MirrorIndex: Int {
    case error = -1
    case abm
    case pma
    case ih1
    case ih2
}

private let _DownloadServiceSharedInstance = DownloadService()

class DownloadService: NSObject, URLSessionDelegate, URLSessionDownloadDelegate {

    @objc class func sharedInstance() -> DownloadService {
        return _DownloadServiceSharedInstance
    }

    // var mirrors: Array<String?> = [String?](count:4, repeatedValue: nil)
    var handlerQueue: [String: CompleteHandlerBlock]!
    @objc var session: Foundation.URLSession!
    @objc var sessionConfiguration: URLSessionConfiguration!

    override init() {
        super.init()
        self.sessionConfiguration = URLSessionConfiguration.background(withIdentifier: identifier)
        self.sessionConfiguration.httpMaximumConnectionsPerHost = 5
        self.session = Foundation.URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
    }

    // MARK: completion handler
    @objc func addCompletionHandler(_ handler: @escaping CompleteHandlerBlock, identifier: String) {
        handlerQueue[identifier] = handler
    }

    @objc func callCompletionHandlerForSession(_ identifier: String!) {
        if let handler: CompleteHandlerBlock = handlerQueue[identifier] {
            handlerQueue!.removeValue(forKey: identifier)
            handler()
        }
    }

    func getAudioChapterWithTaskIdentifier(_ taskIdentifier: Int) -> AudioChapter? {
        for  chapter in dollar.currentReciter.audioChapters {
            if chapter.taskIdentifier == taskIdentifier {
                return chapter
            }
        }
        return nil
    }

    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        print("session error: \(error?.localizedDescription).")
    }

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("session \(session) has finished the download task \(downloadTask) of URL \(location).")

        if let audiChapter: AudioChapter = getAudioChapterWithTaskIdentifier(downloadTask.taskIdentifier) {
            let fm: FileManager = FileManager.default

            if fm.fileExists(atPath: audiChapter.downloadLocation) {
                do {
                    try fm.removeItem(atPath: audiChapter.downloadLocation)
                } catch _ {
                }
            }

            // if (location.absoluteString?.pathExtension == "gzip") {
                // print(audiChapter.downloadFolder)
                // when expanding the zip file, the chapter filder name will be automaticatly created

                do {
                    try NVHTarGzip.sharedInstance().unTarGzipFile(atPath: location.path, toPath: audiChapter.downloadFolder + audiChapter.folderName)

                // if SSZipArchive.unzipFileAtPath(location.path!, toDestination: audiChapter.downloadFolder) {

                    // Change the flag values of the respective audiChapter object.
                    audiChapter.isDownloading = false

                    // Set the initial value to the taskIdentifier property of the fdi object,
                    // so when the start button gets tapped again to start over the file download.
                    audiChapter.taskIdentifier = -1

                    // In case there is any resume data stored in the fdi object, just make it nil.
                    audiChapter.taskResumeData = nil

                    audiChapter.isRetrying = false

                    // Notify the ui about those changes
                    OperationQueue.main.addOperation({
                        NotificationCenter.default.post(name: Notification.Name(rawValue: kDownloadCompleteNotification), object: nil, userInfo: ["audiChapter": audiChapter])
                    })

                    do {
                        // remove the temp file
                        try fm.removeItem(atPath: location.path)
                    } catch _ {
                    }
                } catch _ {
                    // Something went wrong, it seems the file couldn't be downloaded from the mirror
                    // Notify the ui about those changes
                    OperationQueue.main.addOperation({
                        NotificationCenter.default.post(name: Notification.Name(rawValue: kDownloadErrorNotification), object: nil, userInfo: ["audiChapter": audiChapter])
                    })
                }
//            }
//            else {
//                //print(audiChapter.downloadFolder)
//                // when expanding the zip file, the chapter filder name will be automaticatly created
//                if SSZipArchive.unzipFileAtPath(location.path!, toDestination: audiChapter.downloadFolder) {
//                    
//                    // Change the flag values of the respective audiChapter object.
//                    audiChapter.isDownloading = false
//                    
//                    // Set the initial value to the taskIdentifier property of the fdi object,
//                    // so when the start button gets tapped again to start over the file download.
//                    audiChapter.taskIdentifier = -1
//                    
//                    // In case there is any resume data stored in the fdi object, just make it nil.
//                    audiChapter.taskResumeData = nil
//                    
//                    audiChapter.isRetrying = false
//                    
//                    // Notify the ui about those changes
//                    NSOperationQueue.mainQueue().addOperationWithBlock({
//                        NSNotificationCenter.defaultCenter().postNotificationName(kDownloadCompleteNotification, object: nil,  userInfo:["audiChapter": audiChapter])
//                    })
//
//                    do {
//                        // remove the temp file
//                        try fm.removeItemAtPath(location.path!)
//                    } catch _ {
//                    }
//                }
//                else{
//                    // Something went wrong, it seems the file couldn't be downloaded from the mirror
//                    // Notify the ui about those changes
//                    NSOperationQueue.mainQueue().addOperationWithBlock({
//                        NSNotificationCenter.defaultCenter().postNotificationName(kDownloadErrorNotification, object: nil,  userInfo:["audiChapter": audiChapter])
//                    })
//                }
//            }

        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        // println("session \(session) download task \(downloadTask) wrote an additional \(bytesWritten) bytes (total \(totalBytesWritten) bytes) out of an expected \(totalBytesExpectedToWrite) bytes.")

        if totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown {
//            println("Unknown transfer size");
        } else {
            // locate the audio chapter being downloaded based on the task indentifier 
            if let audiChapter: AudioChapter = getAudioChapterWithTaskIdentifier(downloadTask.taskIdentifier) {
                OperationQueue.main.addOperation({
                    // Calculate the progress.
                    let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
                    if Int(progress  * 100) != 100 {
                        audiChapter.downloadProgress = progress
                        NotificationCenter.default.post(name: Notification.Name(rawValue: kProgressUpdatedNotification), object: nil, userInfo: ["audiChapter": audiChapter])
                    }
                })
            }
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        print("session \(session) download task \(downloadTask) resumed at offset \(fileOffset) bytes out of an expected \(expectedTotalBytes) bytes.")
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error == nil {
            print("session \(session) download completed")

            /*
            if !session.configuration.identifier!.isEmpty {
                callCompletionHandlerForSession(session.configuration.identifier)
            }
            
            session.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) -> Void in
                if downloadTasks.count == 0 /*!self.hasPendingTasks(downloadTasks)*/ {
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        let localNotification = UILocalNotification()
                        localNotification.alertBody = "All audios have been downloaded!".local;
                        UIApplication.sharedApplication().presentLocalNotificationNow(localNotification)
                    })
                }
            }
    */
        } else {
            print("session \(session) download failed with error \(error?.localizedDescription)")
            if let audiChapter: AudioChapter = getAudioChapterWithTaskIdentifier(task.taskIdentifier) {
                // Something went wrong, it seems the file couldn't be downloaded from the mirror
                // Notify the ui about those changes
                OperationQueue.main.addOperation({
                    NotificationCenter.default.post(name: Notification.Name(rawValue: kDownloadErrorNotification), object: nil, userInfo: ["audiChapter": audiChapter])
                })
            }
        }
    }

//    func hasPendingTasks(downloadTasks: [NSURLSessionDownloadTask])-> Bool {
//        var output: Bool = false
//        for task in downloadTasks {
//            if task.state != .Completed {
//                output = true
//                break
//            }
//        }
//        return output
//    }

    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        print("background session \(session) finished events.")

//        if !session.configuration.identifier!.isEmpty {
//            callCompletionHandlerForSession(session.configuration.identifier)
//        }
//        
//        session.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) -> Void in
//            if downloadTasks.count == 0 {
//                NSOperationQueue.mainQueue().addOperationWithBlock({
//                    let localNotification = UILocalNotification()
//                    localNotification.alertBody = "All audios have been downloaded!".local;
//                    UIApplication.sharedApplication().presentLocalNotificationNow(localNotification)
//                })
//            }
//        }
    }
}

class PlistDownloader {
    // http://stackoverflow.com/questions/30722971/swift-datataskwithrequest-completion-block-not-executed

    class func load(_ url: String, finished: @escaping (NSObject) -> Void, fault: @escaping (NSError) -> Void) {
        let dest = URL(string: url)
        let request = URLRequest(url: dest!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5.0)
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, _, error in
            if error != nil {
                fault(error! as NSError)
            } else {
                let v: NSArray?
                do {
                    v = try PropertyListSerialization.propertyList(from: data!, options: PropertyListSerialization.MutabilityOptions(), format: nil) as? NSArray
                    finished(v!)
                } catch {
                    v = nil
                }
            }
        })
        task.resume()
    }
}

// Simplfy the data manager call to the $$ sign
var DS: DownloadService = DownloadService.sharedInstance()
