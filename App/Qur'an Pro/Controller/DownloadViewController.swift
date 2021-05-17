//
//  DownloadViewController.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
// Copyright (c) 2015 Islamhome.info. All rights reserved.
//

import UIKit

class DownloadViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var downloadAllButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    var reciter: Reciter!
    var cancelAll: Bool!
    var multipleDownload: Bool!
    var errorWasShown: Bool!
    var firstNotDownloadedAudioChapter: AudioChapter?
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerNotification()
        overrideBackButton()
        downloadAllButton.isEnabled = !isDownloading() && isPro
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Download".local
        reciter = dollar.currentReciter
        cancelAll = false
        multipleDownload = false
        firstNotDownloadedAudioChapter = nil
        errorWasShown = false
    }
    
    @objc func registerNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(DownloadViewController.progressUpdatedHandler(_:)), name:NSNotification.Name(rawValue: kProgressUpdatedNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DownloadViewController.downloadCompleteHandler(_:)), name:NSNotification.Name(rawValue: kDownloadCompleteNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DownloadViewController.downloadErrorHandler(_:)), name:NSNotification.Name(rawValue: kDownloadErrorNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DownloadViewController.downloadStartedHandler(_:)), name:NSNotification.Name(rawValue: kDownloadStartedNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DownloadViewController.downloadDeadHandler(_:)), name:NSNotification.Name(rawValue: kDownloadDeadNotification), object: nil)
    }
    
    // MARK: Table View Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reciter.audioChapters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DownloadCellIdentifier") as! DownloadCell
        let audioChapter:AudioChapter = reciter.audioChapters[indexPath.row] as AudioChapter
        let chapter:Chapter = dollar.chapters[indexPath.row] as Chapter
        cell.chapterName!.text = "\(chapter.id + 1). \(chapter.name.local)"
        cell.downloadState!.text = audioChapter.isDownloaded ? "Downloaded ✅".local.uppercased() : "Download".local.uppercased()
        cell.downloadState!.textColor = audioChapter.isDownloaded ? kAppColor :  kCellTextLabelColor
        cell.downloadState.font = audioChapter.isDownloaded ? kDownloadedFont : kDownloadFont
        cell.downlaodSize!.text = audioChapter.sizeDisplay
        
        // Depending on whether the current file is being downloaded or not, specify the status
        // of the progress bar and the couple of buttons on the cell.
        if (!audioChapter.isDownloaded && (audioChapter.isDownloading || audioChapter.downloadPaused || audioChapter.isRetrying)) {
            // Show the progress view and update its progress, change the image of the start button so it shows
            // a pause icon, and enable the stop button.
            cell.downloadPercentage.isHidden = false
            cell.progressView.isHidden = false
            cell.downloadState.isHidden = true
            cell.downlaodSize.isHidden = true
            cell.progressView.progress = CGFloat(audioChapter.downloadProgress)
            cell.downloadPercentage.text = "\(Int(audioChapter.downloadProgress  * 100))%"
            if !isPro {
                if chapter.id != 0 && chapter.id != 1 {
                    cell.lock()
                }
                else{
                    cell.unlock()
                }
            }
            
        }
        else {
            cell.progressView.isHidden = true
            cell.downloadPercentage.isHidden = true
            cell.downloadState.isHidden = false
            cell.downlaodSize.isHidden = false
            if !isPro {
                if chapter.id != 0 && chapter.id != 1 {
                    cell.lock()
                }
                else{
                    cell.unlock()
                }
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kHeightForRowAtIndexPath
    }
    
    // Mark: Table View Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: DownloadCell  = tableView.cellForRow(at: indexPath) as! DownloadCell
        let audioChapter:AudioChapter = reciter.audioChapters[indexPath.row] as AudioChapter
        func didSelectHandler() {
            cell.contentView.backgroundColor = kSelectedCellBackgroudColor
            // Do nothing the the audio if it is already downloaded
            if !multipleDownload && !audioChapter.isDownloaded && !audioChapter.isDownloading {
                self.startDownload(audioChapter, handler: { () -> Void in
                    tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
                })
            }
            else if audioChapter.isDownloaded  || audioChapter.isDownloading {
                createActionSheet(audioChapter, cell: cell)
            }
        }
        if isPro {
            didSelectHandler()
        }
        else{
            if audioChapter.id == 0 || audioChapter.id == 1 {
                didSelectHandler()
            }
            else{
                self.askUserForPurchasingProVersion(FlurryEvent.downloadFromRow)
            }
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    @objc func startFirstOfAllDownloadsNow(){
        cancelAll = false
        multipleDownload = true
        // first download the first element of the array
        // in order be sure that we are dealing with the correct url
        firstNotDownloadedAudioChapter = getNextAudioChapterToDownload()
        if firstNotDownloadedAudioChapter != nil {
            // Disable the download all button
            downloadAllButton.isEnabled = false
            startDownloadNow(firstNotDownloadedAudioChapter!)
        }
    }
    
    @objc func startAllDownloadsNow() {
        var i:Int = 0
        // Access the first 10  AudioChapter objects using a loop.
        for audioChapter in reciter.audioChapters {
            
            // Check if a file is already being downloaded or not.
            if !audioChapter.isDownloaded && !audioChapter.isDownloading {
                // Check if should create a new download task using a URL, or using resume data.
                if audioChapter.taskIdentifier == -1 || audioChapter.taskResumeData == nil {
                    //audioChapter.
                    urlRequest(audioChapter, resultHandler: { request in
                        if request != nil {
                            audioChapter.downloadTask = DS.session.downloadTask(with: request!)
                            audioChapter.taskIdentifier = audioChapter.downloadTask!.taskIdentifier
                            
                            // Start the task.
                            audioChapter.downloadTask?.resume()
                            // Indicate for each file that is being downloaded.
                            audioChapter.isDownloading = true
                            audioChapter.downloadPaused = false
                            NotificationCenter.default.post(name: Notification.Name(rawValue: kDownloadStartedNotification), object: nil,  userInfo:["audiChapter": audioChapter])
                            i = i + 1;//i++
                        }
                    })
                }
                else {
                    audioChapter.downloadTask = DS.session.downloadTask(withResumeData: audioChapter.taskResumeData!)
                    // Indicate for each file that is being downloaded.
                    audioChapter.isDownloading = true
                    audioChapter.downloadPaused = false
                    NotificationCenter.default.post(name: Notification.Name(rawValue: kDownloadStartedNotification), object: nil,  userInfo:["audiChapter": audioChapter])
                    i += 1
                }
            }
            
            // Break on 6 items otherwise the UI will freeze
            if i == 5 {
                break
            }
        }
        
        if i > 0 {
            // Disable the download all button
            downloadAllButton.isEnabled = false
            
            // Reload the table view.
            tableView.reloadData()
        }
    }
    
    @IBAction func startAllDownloads(_ sender: AnyObject) {
        confirmDownload(startFirstOfAllDownloadsNow)
        //Flurry.logEvent(FlurryEvent.downloadAll, withParameters: ["reciter" : reciter.name])
    }
    
    @objc func confirmDownload(_ callBack: @escaping () -> ()) {
        let alert = UIAlertController(title: "Info".local, message: nil, preferredStyle: .actionSheet)
        if IJReachability.isConnectedToNetworkOfType() == IJReachabilityType.wiFi || (dollar.allowDownloadOn3G && IJReachability.isConnectedToNetworkOfType() == IJReachabilityType.wwan ){
            callBack()
        }
        else if IJReachability.isConnectedToNetworkOfType() == IJReachabilityType.wwan {
            alert.message = "Downloading via 3G/4G connection?".local
            let agreeDownloadOn3G =  UIAlertAction(title: "Continue".local, style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                callBack()
                dollar.allowDownloadOn3G = true
                //Flurry.logEvent(FlurryEvent.downloadFrom3G)
            })
            alert.addAction(agreeDownloadOn3G)
            alert.addAction(UIAlertAction(title: "Cancel".local, style: UIAlertAction.Style.default,handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if IJReachability.isConnectedToNetworkOfType() == IJReachabilityType.notConnected {
            alert.message = "You are not connected to the internet.".local
            alert.addAction(UIAlertAction(title: "Cancel".local, style: UIAlertAction.Style.default,handler: nil))
            self.present(alert, animated: true, completion: nil)
            //Flurry.logEvent(FlurryEvent.downloadNoConnection)
        }
    }
    
    // MARK: Notifications
    
    @objc func progressUpdatedHandler(_ notification: Notification){
        //Action take on Notification
        if let audioChapter: AudioChapter = notification.userInfo!["audiChapter"] as? AudioChapter {
            if let cell: DownloadCell = tableView.cellForRow( at: IndexPath(row: audioChapter.id, section: 0)) as? DownloadCell {
                //cell.progressView.stopSpinProgressBackgroundLayer()
                cell.progressView.progress = CGFloat(audioChapter.downloadProgress)
                cell.downloadPercentage.text = "\(Int(audioChapter.downloadProgress  * 100))%"
            }
        }
    }
    
    @objc func downloadStartedHandler(_ notification: Notification){
        if let notifChapter: AudioChapter = notification.userInfo!["audiChapter"] as? AudioChapter {
            let index: IndexPath = IndexPath(row: notifChapter.id, section: 0)
            tableView.reloadRows(at: [index], with: UITableView.RowAnimation.none)
        }
    }
    
    @objc func downloadCompleteHandler(_ notification: Notification){
        if let audioChapter: AudioChapter = notification.userInfo!["audiChapter"] as? AudioChapter {
            tableView.reloadRows(at: [IndexPath(row: audioChapter.id, section: 0)], with: UITableView.RowAnimation.none)
            if let nextToDownload = getNextAudioChapterToDownload() {
                if multipleDownload == true {
                    if firstNotDownloadedAudioChapter != nil {
                        startAllDownloadsNow()
                        firstNotDownloadedAudioChapter = nil
                    }
                    else{
                        let index: IndexPath = IndexPath(row: nextToDownload.id, section: 0)
                        self.startDownload(nextToDownload, handler: { () -> Void in
                            self.tableView.reloadRows(at: [index], with: UITableView.RowAnimation.none)
                        })
                        tableView.reloadRows(at: [index], with: UITableView.RowAnimation.none)
                    }
                }
            }
            else {
                multipleDownload = false
            }
            downloadAllButton.isEnabled = !isDownloading() && isPro
        }
    }
    
    @objc func downloadDeadHandler(_ notification: Notification){
        if notification.userInfo!["audiChapter"] as? AudioChapter != nil {
            let showError: Bool = (multipleDownload == true && !errorWasShown) || !multipleDownload
            if showError {
                // Access all AudioChapter objects using a loop.
                for audioChapter in self.reciter.audioChapters {
                    // Check if a file is already being downloaded or not.
                    if !audioChapter.isDownloaded && audioChapter.isDownloading {
                        audioChapter.reset()
                        audioChapter.downloadTask?.cancel()
                        NotificationCenter.default.post(name: Notification.Name(rawValue: kDownloadCancelAllNotification), object: nil,  userInfo:["audiChapter": audioChapter])
                    }
                }
                
                self.downloadAllButton.isEnabled = isPro
                self.cancelAll = true
                self.tableView.reloadData()
                showDownloadError()
            }
        }
    }
    
    @objc func downloadErrorHandler(_ notification: Notification){
        if let audioChapter: AudioChapter = notification.userInfo!["audiChapter"] as? AudioChapter {
            if dollar.currentReciter.mirrorIndex == MirrorIndex.error {
                //puff we have an issue here
            }
            else if dollar.currentReciter.mirrorIndex != MirrorIndex.ih2 {
                dollar.currentReciter.mirrorIndex = MirrorIndex(rawValue: dollar.currentReciter.mirrorIndex.rawValue + 1)!
                //try again
                startDownload(audioChapter, handler: { () -> Void in
                    audioChapter.isRetrying = true
                    self.tableView.reloadRows(at: [IndexPath(row: audioChapter.id, section: 0)], with: UITableView.RowAnimation.none)
                })
                
            }
            //last mirror not found so show the error
            else{
                dollar.currentReciter.mirrorIndex = MirrorIndex.error
                tableView.reloadRows(at: [IndexPath(row: audioChapter.id, section: 0)], with: UITableView.RowAnimation.none)
                showDownloadError()
            }
        }
    }
    
    // MARK: Actionsheet
    
    func createActionSheet(_ audioChapter: AudioChapter, cell: DownloadCell) {
        
        let sportAllDownloadsAction =  UIAlertAction(title: "Stop All Downloads".local, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            var hasAtLeastOneDownload = false
            // Access all AudioChapter objects using a loop.
            for audioChapter in self.reciter.audioChapters {
                // Check if a file is already being downloaded or not.
                if !audioChapter.isDownloaded && audioChapter.isDownloading {
                    audioChapter.reset()
                    audioChapter.downloadTask?.cancel()
                    hasAtLeastOneDownload = true
                    NotificationCenter.default.post(name: Notification.Name(rawValue: kDownloadCancelAllNotification), object: nil,  userInfo:["audiChapter": audioChapter])
                }
            }
            
            if hasAtLeastOneDownload {
                self.multipleDownload = false
                self.downloadAllButton.isEnabled = isPro
                self.cancelAll = true
                self.tableView.reloadData()
            }
            
            //Flurry.logEvent(FlurryEvent.stopAllDownloads)
        })
        
        let stopDownloadAction =  UIAlertAction(title: "Stop Download".local, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            // Change the isDownloading property value.
            audioChapter.reset()
            audioChapter.downloadTask?.cancel()
            
            // Reload the table view.
            self.tableView.reloadRows(at: [IndexPath(row: audioChapter.id, section: 0)], with: UITableView.RowAnimation.none)
            self.downloadAllButton.isEnabled = !self.isDownloading() && isPro
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: kDownloadCancelAllNotification), object: nil,  userInfo:nil)
            //Flurry.logEvent(FlurryEvent.stopDownload)
        })
        
        let deleteAudioAction = UIAlertAction(title: "Delete Download".local, style: .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
                do {
                    try FileManager.default.removeItem(atPath: audioChapter.downloadFolder)
                } catch _ {
                }
            audioChapter.reset()
            self.tableView.reloadRows(at: [IndexPath(row: audioChapter.id, section: 0)], with: UITableView.RowAnimation.none)
            NotificationCenter.default.post(name: Notification.Name(rawValue: kAudioRemovedNotification), object: nil,  userInfo:["audiChapter": audioChapter])
            //Flurry.logEvent(FlurryEvent.removeDownload, withParameters: ["fileName" : audioChapter.fileName, "reciter" : self.reciter.name])
        })
        
        let deleteAllAudiosAction = UIAlertAction(title: "Delete All Downloads".local, style: .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
                do {
                    try FileManager.default.removeItem(atPath: audioChapter.reciterFolder)
                } catch _ {
                }
            self.resetAll()
            // Reload the table view.
            self.tableView.reloadData()
            NotificationCenter.default.post(name: Notification.Name(rawValue: kAllAudiosRemovedNotification), object: nil,  userInfo:nil)
            //Flurry.logEvent(FlurryEvent.removeAllDownloads, withParameters: ["reciter" : self.reciter.name])
        })
        
        //
        let dismissAction = UIAlertAction(title: "Cancel".local, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        DS.session.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) -> Void in
            OperationQueue.main.addOperation { () -> Void in
                let alert = UIAlertController(title: self.reciter.name, message: nil, preferredStyle: .actionSheet)
                //execute in the main thread
                if downloadTasks.count == 0 {
                    alert.addAction(deleteAudioAction)
                    alert.addAction(deleteAllAudiosAction)
                }
                else if downloadTasks.count == 1 {
                    alert.addAction(stopDownloadAction)
                }
                else if downloadTasks.count > 1 {
                    alert.addAction(sportAllDownloadsAction)
                }
                //We need to provide a popover sourceView when using it on iPad
                if isIpad {
                    let popPresenter: UIPopoverPresentationController = alert.popoverPresentationController!
                    popPresenter.sourceView = cell;
                    popPresenter.sourceRect = cell.bounds
                }
                
                alert.addAction(dismissAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: Units
    
    // Check if the download is beging performed
    @objc func isDownloading() -> Bool {
        // Access all AudioChapter objects using a loop.
        for audioChapter in reciter.audioChapters {
            if audioChapter.isDownloading {
                return true
            }
        }
        return false
    }

    // Gets the next possible audio item to download
    func getNextAudioChapterToDownload () -> AudioChapter? {
        if (cancelAll == true) {
            return nil
        }
        // Access all AudioChapter objects using a loop.
        var audioChapter: AudioChapter!
        for i in 0...(reciter.audioChapters.count - 1) {
            audioChapter = reciter.audioChapters[i]
            if !audioChapter.isDownloaded && !audioChapter.isDownloading {
                return audioChapter
            }
        }
        
        return nil
    }
    
    @objc func resetAll () {
        for audioChapter in reciter.audioChapters {
            audioChapter.reset()
        }
    }
}
