//
//  UIViewController.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import Foundation

extension UIViewController {
    
    
    @objc func askUserForPurchasingProVersion(_ logsKey: String) {
        //NSNotificationCenter.defaultCenter().postNotificationName(kOpenSKControllerNotification, object: nil,  userInfo: nil)
        FlurryEvent.logPurchase(logsKey)
        UIApplication.shared.openURL(URL(string: kAppUrl.localizeWithFormat(kQuranProId))!)
    }
    
    @objc public func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    @objc func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        if let header: UITableViewHeaderFooterView = view as? UITableViewHeaderFooterView {
            header.textLabel?.font = kSectionBackgrondFont
            header.textLabel?.textColor = UIColor.white
            header.tintColor = kSectionBackgrondColor
        }
    }
    
    @objc func overrideBackButton(){
        let backButton = UIBarButtonItem(image: UIImage(named: "back"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(UIViewController.goBack))
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc func goBack(){
        self.navigationController?.popViewController(animated: true)
    }

    func startDownload (_ audioChapter: AudioChapter, handler: (() -> ())?) {
        let alert = UIAlertController(title: "Info".local, message: nil, preferredStyle: .actionSheet)
        if IJReachability.isConnectedToNetworkOfType() == IJReachabilityType.wiFi || (dollar.allowDownloadOn3G && IJReachability.isConnectedToNetworkOfType() == IJReachabilityType.wwan ){
            startDownloadNow(audioChapter)
            handler?()
        }
        else if IJReachability.isConnectedToNetworkOfType() == IJReachabilityType.wwan {
            alert.message = "Downloading via 3G/4G connection?".local
            let agreeDownloadOn3G =  UIAlertAction(title: "Continue".local, style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.startDownloadNow(audioChapter)
                // Reload the table view.
                handler?()
                //tableView?.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
                dollar.allowDownloadOn3G = true
            })
            alert.addAction(agreeDownloadOn3G)
            alert.addAction(UIAlertAction(title: "Cancel".local, style: UIAlertAction.Style.default,handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if IJReachability.isConnectedToNetworkOfType() == IJReachabilityType.notConnected {
            alert.message = "You are not connected to the internet.".local
            alert.addAction(UIAlertAction(title: "Cancel".local, style: UIAlertAction.Style.default,handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func startDownloadNow (_ audioChapter: AudioChapter) {
        if audioChapter.taskIdentifier == -1 || audioChapter.taskResumeData == nil {
            // Create a new task, but check whether it should be created using a URL or resume data.
            
            urlRequest(audioChapter, resultHandler: { request in
                if request != nil {
                    audioChapter.downloadTask = DS.session.downloadTask(with: request!)
                    audioChapter.taskIdentifier = audioChapter.downloadTask!.taskIdentifier
                    
                    // Start the task.
                    audioChapter.downloadTask?.resume()
                }
                else{
                    OperationQueue.main.addOperation({
                        //handle the error here....
                        NotificationCenter.default.post(name: Notification.Name(rawValue: kDownloadDeadNotification), object: nil,  userInfo:["audiChapter": audioChapter])
                        //Flurry.logEvent(FlurryEvent.downloadDead)
                    })
                }
            })
        }
        else {
            // Create a new download task, which will use the stored resume data.
            audioChapter.downloadTask = DS.session.downloadTask(withResumeData: audioChapter.taskResumeData!)
            audioChapter.downloadTask?.resume()
            // Keep the new download task identifier.
            audioChapter.taskIdentifier = audioChapter.downloadTask!.taskIdentifier;
        }
        
        // Change the isDownloading property value.
        audioChapter.isDownloading = !audioChapter.isDownloading;
        NotificationCenter.default.post(name: Notification.Name(rawValue: kDownloadStartedNotification), object: nil,  userInfo:["audiChapter": audioChapter])
    }

    // Gets the url request based on the current mirror
    func urlRequest(_ audioChapter:AudioChapter, resultHandler:@escaping (URLRequest?)->()) {
        var kMirror:String?
        //we have an error state here
        if dollar.currentReciter.mirrorIndex == MirrorIndex.error {
            resultHandler(nil)
        }
        if dollar.currentReciter.mirrorIndex == MirrorIndex.ih1 || dollar.currentReciter.mirrorIndex == MirrorIndex.ih2 {
            if dollar.currentReciter.mirrorIndex == MirrorIndex.ih1 && dollar.currentReciter.mirrors[MirrorIndex.ih1.rawValue] != nil {
                kMirror = dollar.currentReciter.mirrors[MirrorIndex.ih1.rawValue]! + audioChapter.fileName
            }
            else if dollar.currentReciter.mirrorIndex == MirrorIndex.ih2 && dollar.currentReciter.mirrors[MirrorIndex.ih2.rawValue] != nil {
                kMirror = dollar.currentReciter.mirrors[MirrorIndex.ih2.rawValue]! + audioChapter.fileName
            }
            else{
                //download the new mirror list from bitbucket repo
                PlistDownloader.load(kDownloadMirrorUrl, finished: { result in
                    if let list: Array<NSDictionary> = result as? Array<NSDictionary> {
                        //if let dic: NSDictionary = list[dollar.currentReciter.id] {
                            let dic: NSDictionary = list[dollar.currentReciter.id]
                            if let m1: String = dic.object(forKey: "m1") as? String {
                                dollar.currentReciter.mirrors[MirrorIndex.ih1.rawValue] = m1
                                kMirror = dollar.currentReciter.mirrors[MirrorIndex.ih1.rawValue]! + audioChapter.fileName
                            }
                            if let m2: String = dic.object(forKey: "m2") as? String {
                                dollar.currentReciter.mirrors[MirrorIndex.ih2.rawValue] = m2
                                if kMirror == nil {
                                    kMirror = dollar.currentReciter.mirrors[MirrorIndex.ih2.rawValue]! + audioChapter.fileName
                                }
                            }

                            if kMirror != nil {
                                resultHandler(URLRequest(url: URL(string: kMirror!)!))
                            }
                        //}
                    }
                    }, fault: {error in
                        resultHandler(nil)
                })
            }
        }
        else if dollar.currentReciter.mirrorIndex == MirrorIndex.abm {
            kMirror = dollar.currentReciter.mirrors[MirrorIndex.abm.rawValue]! + audioChapter.fileName
        }
        else if dollar.currentReciter.mirrorIndex == MirrorIndex.pma {
            kMirror = dollar.currentReciter.mirrors[MirrorIndex.pma.rawValue]! + audioChapter.fileName
        }

        if kMirror != nil {
            resultHandler(URLRequest(url: URL(string: kMirror!)!))
        }
        else{
            resultHandler(nil)
        }
    }
    
    @objc func showDownloadError() {
        let alertController = UIAlertController(title: "Info".local, message:
            "Something went wrong during downloading, please try later on again.".local, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Cancel".local, style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
        let moreInfo = "[currentKey: \(dollar.currentLanguageKey), NSUserDefaultsLanguageKey: \(UserDefaults.currentLanguageKey())]"
        //Flurry.logError(FlurryEvent.downloadError, message: "Something went wrong during downloading, please try later on again. \(moreInfo)", error: nil)
    }

}
