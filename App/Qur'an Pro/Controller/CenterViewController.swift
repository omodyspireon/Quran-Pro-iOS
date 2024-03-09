//
//  CenterViewController.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import UIKit
import Social
import AVFoundation

@objc
protocol CenterViewControllerDelegate {
    @objc optional func toggleChaptersPanel()
    @objc optional func toggleMorePanel()
    @objc optional func collapseSidePanels()
    @objc optional func isPanelVisble() -> Int
}

class CenterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, AudioDelegate {
    
    @objc let service: AudioService = AudioService.sharedInstance()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progress: UIProgressView!
    @objc var activityIndicatorView: UIActivityIndicatorView!
    @objc var originalTitleView: UIView!
    @objc var originalLeftBarButtonItems: [AnyObject]?
    @objc var currentArabicFont: UIFont!
    @objc var currentLatinFont: UIFont!
    
    @objc var isScrolling: Bool = false
    @objc var currentVerseIndex: Int = 0
    var currentAudioChapter: AudioChapter!
    @objc var delegate: CenterViewControllerDelegate?
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        service.initDelegation(self)
        // navigationController?.hidesBarsOnSwipe = true
        originalTitleView = self.navigationItem.titleView
        originalLeftBarButtonItems = self.navigationItem.leftBarButtonItems
        currentAudioChapter = dollar.currentReciter.audioChapters[dollar.currentChapter.id]
        activityIndicatorView = UIActivityIndicatorView(style: .medium)
        activityIndicatorView.startAnimating()
        progress.setProgress(0, animated: false)
        view.sendSubviewToBack(tableView)
        updateControls()
        tableViewReloadData()
        registerNotification()
        updateFont()
    }
    
    // update to the font to use
    @objc func updateFont() {
        currentArabicFont = UIFont.arabicFont()
        currentLatinFont = UIFont.latin()
    }
    @objc func registerNotification() {
        let notifier: NotificationCenter = NotificationCenter.default
        notifier.addObserver(self, selector: #selector(CenterViewController.newChapterSelectedHandler(_:)), name: NSNotification.Name(rawValue: kNewChapterSelectedNotification), object: nil)
        notifier.addObserver(self, selector: #selector(CenterViewController.newVerseSelectedHandler(_:)), name: NSNotification.Name(rawValue: kNewVerseSelectedNotification), object: nil)
        notifier.addObserver(self, selector: #selector(CenterViewController.progressUpdatedHandler(_:)), name: NSNotification.Name(rawValue: kProgressUpdatedNotification), object: nil)
        notifier.addObserver(self, selector: #selector(CenterViewController.downloadStartedHandler(_:)), name: NSNotification.Name(rawValue: kDownloadStartedNotification), object: nil)
        notifier.addObserver(self, selector: #selector(CenterViewController.downloadCompleteHandler(_:)), name: NSNotification.Name(rawValue: kDownloadCompleteNotification), object: nil)
        notifier.addObserver(self, selector: #selector(CenterViewController.downloadDeadHandler(_:)), name: NSNotification.Name(rawValue: kDownloadDeadNotification), object: nil)
        notifier.addObserver(self, selector: #selector(CenterViewController.downloadErrorHandler(_:)), name: NSNotification.Name(rawValue: kDownloadErrorNotification), object: nil)
        notifier.addObserver(self, selector: #selector(CenterViewController.downloadCancelHandler(_:)), name: NSNotification.Name(rawValue: kDownloadCancelNotification), object: nil)
        notifier.addObserver(self, selector: #selector(CenterViewController.downloadCancelAllHandler(_:)), name: NSNotification.Name(rawValue: kDownloadCancelAllNotification), object: nil)
        notifier.addObserver(self, selector: #selector(CenterViewController.audioRemovedHandler(_:)), name: NSNotification.Name(rawValue: kAudioRemovedNotification), object: nil)
        notifier.addObserver(self, selector: #selector(CenterViewController.allAudiosRemovedHandler(_:)), name: NSNotification.Name(rawValue: kAllAudiosRemovedNotification), object: nil)
        notifier.addObserver(self, selector: #selector(CenterViewController.reciterChangedHandler(_:)), name: NSNotification.Name(rawValue: kReciterChangedNotification), object: nil)
        notifier.addObserver(self, selector: #selector(CenterViewController.translationChangedHandler(_:)), name: NSNotification.Name(rawValue: kTranslationChangedNotification), object: nil)
        notifier.addObserver(self, selector: #selector(CenterViewController.viewChangedHandler(_:)), name: NSNotification.Name(rawValue: kViewChangedNotification), object: nil)
        notifier.addObserver(self, selector: #selector(CenterViewController.bookmarksRemovedHandler(_:)), name: NSNotification.Name(rawValue: kBookmarksRemovedNotification), object: nil)
        notifier.addObserver(self, selector: #selector(CenterViewController.beginReceivingRemoteControlEventsHandler(_:)), name: NSNotification.Name(rawValue: kBeginReceivingRemoteControlEvents), object: nil)
    }
    
    @objc func updatePlayControls() {
        let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
        label.text = "\(dollar.currentChapter.name) - \(dollar.currentReciter.name)"
        let closePlayControlerBtn: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.stop, target: self, action: #selector(CenterViewController.closePlayControlClickedHandler))
        
        let repeatBtn: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: service.repeatIconName()), style: UIBarButtonItem.Style.plain, target: self, action: #selector(CenterViewController.repeatClickedHandler))
        repeatBtn.isEnabled = isPro

        let speedBtn: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: service.speedIconName()), style: UIBarButtonItem.Style.plain, target: self, action: #selector(CenterViewController.speedClickedHandler))
        // speedBtn.imageInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, kUIBarButtonItemUIEdgeInsetsAudioRight-40);

        let resumeBtn: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "play"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(CenterViewController.resumeClickedHandler))
        resumeBtn.imageInsets = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: 0.0, right: kUIBarButtonItemUIEdgeInsetsAudioRight/2);
        
        let pauseBtn: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "pause"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(CenterViewController.pauseClickedHandler))
        pauseBtn.imageInsets = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: 0.0, right: kUIBarButtonItemUIEdgeInsetsAudioRight/2);
        
        let nextBtn: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "next"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(CenterViewController.nextClickedHandler))
        
        let previousBtn: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "previous"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(CenterViewController.previousClickedHandler))
        // previousBtn.imageInsets = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: 0.0, right: kUIBarButtonItemUIEdgeInsetsAudioRight);
        
        var playControlItems: Array<UIBarButtonItem> = []
        playControlItems = [closePlayControlerBtn, nextBtn, previousBtn]
        if service.isPlaying() {
            playControlItems.insert(pauseBtn, at: playControlItems.count - 1)
        }
        else {
            playControlItems.insert(resumeBtn, at: playControlItems.count - 1)
        }
        
        // self.navigationItem.rightBarButtonItems = [closePlayControlerBtn, nextBtn, pauseBtn, previousBtn]
        self.navigationItem.rightBarButtonItems = playControlItems
        self.navigationItem.leftBarButtonItems = [repeatBtn, speedBtn]
        navigationItem.titleView = UIView(frame: CGRect())
    }
    
    // Update the controls depending on the state of the audio file
    @objc func updateControls() {
        
        // when plying
        if service.isPlaying() || service.isPaused == true {
            updatePlayControls()
            return
        }
        
        // chapters.png
        let downloadImageName = "download_cloud" + (!isPro && currentAudioChapter.id != 0 && currentAudioChapter.id != 1  ? "-disabled" : "")
        let downloadBtn: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: downloadImageName), style: UIBarButtonItem.Style.plain, target: self, action: #selector(CenterViewController.downloadClickedHandler))
        downloadBtn.imageInsets = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: 0.0, right: kUIBarButtonItemUIEdgeInsetsRight);
        let showAudioControlBtn: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "show-audio-controls"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(CenterViewController.showAudioControlsHandler))
        
        showAudioControlBtn.imageInsets = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: 0.0, right: kUIBarButtonItemUIEdgeInsetsRight);
        
        let activityIndicatorBtn: UIBarButtonItem = UIBarButtonItem(customView: activityIndicatorView)
        activityIndicatorBtn.imageInsets = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: 0, right: 20);

        let moreBtn: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "more"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(CenterViewController.toggleMorePanel(_:)))
        
        var buttons: Array<UIBarButtonItem> = [moreBtn]
        if currentAudioChapter.isDownloaded {
            buttons.append(showAudioControlBtn)
        }
        else if currentAudioChapter.isDownloading {
            buttons.append(activityIndicatorBtn)
        }
        else {
            buttons.append(downloadBtn)
        }
        self.navigationItem.rightBarButtonItems = buttons
        self.navigationItem.leftBarButtonItems = originalLeftBarButtonItems as? [UIBarButtonItem]
        self.navigationItem.titleView = originalTitleView
        progress.isHidden = false
        // update the progress comtrol
        if currentAudioChapter != nil && currentAudioChapter.isDownloading {
            view.bringSubviewToFront(progress)
            progress.trackTintColor = UIColor.white
            progress.setProgress(currentAudioChapter.downloadProgress, animated: false)
        }
        else {
            view.sendSubviewToBack(progress)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // sets the title
        self.title = "\(dollar.currentChapter.id + 1). \(dollar.currentChapter.name.local)"
        self.tableView.estimatedRowHeight = 120.0
        self.tableView.rowHeight = UITableView.automaticDimension
    }
    
    // MARK: Actions
    
    @IBAction func toggleChapterPanel(_ sender: AnyObject) {
        // Flurry.logEvent(FlurryEvent.toggleChapterPanel)
        delegate?.toggleChaptersPanel!()
    }
    
    @IBAction func toggleMorePanel(_ sender: AnyObject) {
        // Flurry.logEvent(FlurryEvent.toggleMorePanel)
        delegate?.toggleMorePanel!()
    }
    
    // MARK: Table View Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dollar.currentChapter.verses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "VerseCellIdentifier"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! VerseCell
        
        let verse = dollar.currentChapter.verses[indexPath.row]
        // set up the font
        cell.arabic.font = currentArabicFont
        cell.translation.font = currentLatinFont
        cell.transcription.font = currentLatinFont
        
        // set up the content
        contentForCell(verse, cell: cell)
        
        // set up the bookmark icons
        cell.bookmarkView.isHidden = !BookmarkService.sharedInstance().has(verse)
        
        // hold a reference of the verse id into the cell
        cell.verseId = verse.id
        
        // set the background for the verse view depending on the odd/event index and the hizb option
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = verse.hizbId != -1 ? kHizbTableCellColor : ((indexPath.row % 2) == 0) ? kVerseCellyOddColor : kVerseCellyEvenColor
        cell.backgroundView = view
        
        // needed to fix an issue with UITableViewAutomaticDimension not working until scroll
        // http://useyourloaf.com/blog/2014/08/07/self-sizing-table-view-cells.html
        // cell.setNeedsDisplay()
        cell.layoutIfNeeded()
        
        // return the cell
        return cell
    }
    
    // get the content representation depending on the settings
    fileprivate func contentForCell (_ verse: Verse, cell: VerseCell) {
        // "﴾﴿"
        let numbers = "\(verse.chapterId + 1):\(verse.id)"
        cell.arabic.text = !dollar.showTranslation ? verse.translation != "" ? "\(numbers)  \(verse.arabic)" : verse.arabic : verse.arabic
        cell.transcription.text = dollar.showTransliteration ?  verse.transcription : ""
        cell.translation.text = dollar.showTranslation ? verse.translation != "" ? "\(numbers) \(verse.translation)" : "" : ""

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.delegate?.isPanelVisble!() == 1 {
            self.delegate?.collapseSidePanels!()
            let cell: VerseCell  = tableView.cellForRow(at: indexPath) as! VerseCell
            cell.contentView.backgroundColor = kSelectedCellBackgroudColor
            tableView.deselectRow(at: indexPath, animated: false)
        } else {
            let cell: VerseCell  = tableView.cellForRow(at: indexPath) as! VerseCell
            cell.contentView.backgroundColor = kSelectedCellBackgroudColor
            let verse = dollar.currentChapter.verses[indexPath.row]
            
            if verse.id != -1 {
                showActionSheetAlert(verse, cell: cell)
            }
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    
    // TODO remove this if not needed anymore
    // needed to fix an issue with UITableViewAutomaticDimension not working until scroll
    @objc func tableViewReloadData() {
        tableView.reloadData()
        // tableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(0, self.tableView.numberOfSections())), withRowAnimation: .None)
    }
    
    // MARK: Notifications
    
    // handle the new chapter selection
    @objc func newChapterSelectedHandler(_ notification: Notification) {
        // sets the title
         if let userInfo = notification.userInfo {
            if let chapter: Chapter = userInfo["chapter"] as? Chapter {
                if chapter.id != currentAudioChapter.id {
                    if self.service.isPlaying() {
                        self.service.stopAndReset()
                    }
                    self.service.isPaused = false
                    self.title = "\(dollar.currentChapter.id + 1). \(dollar.currentChapter.name.local)"
                    currentAudioChapter = dollar.currentReciter.audioChapters[dollar.currentChapter.id]
                    self.updateControls()
                    tableViewReloadData()
                    self.scrollToVerse(0)
                }
            }
        }
        self.delegate?.toggleChaptersPanel!()
    }
    
    // handle the new verse selection
    @objc func newVerseSelectedHandler(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let verse: Verse = userInfo["verse"] as? Verse {
                let chapter = dollar.chapters[verse.chapterId]
                if chapter.id != dollar.currentChapter.id {
                    if self.service.isPlaying() {
                        self.service.stopAndReset()
                    }
                    self.service.isPaused = false
                    dollar.setAndSaveCurrentChapter(chapter)
                    self.title = "\(chapter.id + 1). \(chapter.name.local)"
                    currentAudioChapter = dollar.currentReciter.audioChapters[dollar.currentChapter.id]
                    tableViewReloadData()
                    updateControls()
                }
                var verserId = verse.id
                // correct the position the of te verse to scroll to
                if (verse.chapterId == kTaubahIndex) || (verse.chapterId == kFatihaIndex) {
                    verserId -= 1
                }
                self.scrollToVerse(verserId, searchText: userInfo["searchText"] as? String)
                if let toggle = userInfo["toggle"] as? String {
                    if toggle == "left"{
                        delegate?.toggleChaptersPanel!()
                    }
                    else {
                        delegate?.toggleMorePanel!()
                    }
                    
                }
            }
        }
    }
    
    @objc func progressUpdatedHandler(_ notification: Notification) {
        // Action take on Notification
        if let notifChapter: AudioChapter = notification.userInfo!["audiChapter"] as? AudioChapter {
            if notifChapter.id == currentAudioChapter.id {
                progress.setProgress(notifChapter.downloadProgress, animated: true)
            }
        }
    }
    
    @objc func downloadStartedHandler(_ notification: Notification) {
        if let notifChapter: AudioChapter = notification.userInfo!["audiChapter"] as? AudioChapter {
            if notifChapter.id == currentAudioChapter.id {
                self.updateControls()
            }
        }
    }
    
    @objc func downloadCompleteHandler(_ notification: Notification) {
        if let notifChapter: AudioChapter = notification.userInfo!["audiChapter"] as? AudioChapter {
            if notifChapter.id == currentAudioChapter.id {
                self.updateControls()
            }
        }
    }
    
    @objc func downloadCancelHandler (_ notification: Notification) {
        if let notifChapter: AudioChapter = notification.userInfo!["audiChapter"] as? AudioChapter {
            if notifChapter.id == currentAudioChapter.id {
                self.updateControls()
            }
        }
    }
    
    @objc func downloadCancelAllHandler (_ notification: Notification) {
        self.updateControls()
    }
    
    @objc func reciterChangedHandler (_ notification: Notification) {
        currentAudioChapter = dollar.currentReciter.audioChapters[dollar.currentChapter.id]
        self.updateControls()
    }
    
    @objc func downloadDeadHandler (_ notification: Notification) {
        if let notifChapter: AudioChapter = notification.userInfo!["audiChapter"] as? AudioChapter {
            if currentAudioChapter.id == notifChapter.id {
                currentAudioChapter.reset()
                self.updateControls()
                showDownloadError()
            }
        }
    }
    
    
    // todo, move this and the downloadview version to a global version
    @objc func downloadErrorHandler(_ notification: Notification) {
        self.updateControls()
//        if let notifChapter: AudioChapter = notification.userInfo!["audiChapter"] as? AudioChapter {
//            if currentAudioChapter.id == notifChapter.id {
//                //self.updateControls()
//                if DS.currentMirrorIndex == MirrorIndex.ERROR {
//                    //puff we have an issue here
//                }
//                else if DS.currentMirrorIndex != MirrorIndex.IH2 {
//                    DS.currentMirrorIndex = MirrorIndex(rawValue: DS.currentMirrorIndex.rawValue + 1)!
//                    //try again
//                    startDownload(currentAudioChapter, handler: { (Void) -> Void in
//                        self.currentAudioChapter.isRetrying = true
//                        self.updateControls()
//                    })
//                    
//                }
//                //last mirror not found so show the error
//                else{
//                    DS.currentMirrorIndex = MirrorIndex.ERROR
//                    self.updateControls()
//                    showDownloadError()
//                }
//                
//            }
//        }
    }
    
    
    // handles the remote control costum events from the delegate
    @objc func beginReceivingRemoteControlEventsHandler(_ notification: Notification) {
        if let event: UIEvent = notification.object as? UIEvent {
            switch event.subtype {
            case .remoteControlTogglePlayPause:
                service.isPlaying() ? pauseClickedHandler() : resumeClickedHandler()
            case .remoteControlPlay:
                resumeClickedHandler()
            case .remoteControlPause:
                pauseClickedHandler()
            case .remoteControlNextTrack:
                nextClickedHandler()
            case .remoteControlPreviousTrack:
                previousClickedHandler()
            default: break
            }
        }
    }
    
    // update the ui contols
    @objc func audioRemovedHandler(_ notification: Notification) {
        if let notifChapter: AudioChapter = notification.userInfo!["audiChapter"] as? AudioChapter {
            if notifChapter.id == currentAudioChapter.id {
                updateControls()
            }
        }
    }
    
    // update the ui contols
    @objc func allAudiosRemovedHandler(_ notification: Notification) {
        updateControls()
    }

    // update the ui contols
    @objc func translationChangedHandler(_ notification: Notification) {
        tableViewReloadData()
    }
    
    // update the ui contols
    @objc func viewChangedHandler(_ notification: Notification) {
        updateFont()
        tableViewReloadData()
    }

    // update the bookmarks
    @objc func bookmarksRemovedHandler(_ notification: Notification) {
        tableViewReloadData()
    }

    // MARK: - Scrolling delegate handlers

    // Saves the scrolling state
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.isScrolling = true
    }
    
    // Saves the middle verse id when scrolling was stopped.
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.isScrolling = false
        let visibleCells = tableView.visibleCells
        let middleItemIndex = visibleCells.count / 2
        if let verseCell: VerseCell = visibleCells[middleItemIndex] as? VerseCell {
            self.currentVerseIndex = verseCell.verseId
        }
    }
    
    // Scroll the provided verseId
    // @param verseId   the verse index to scroll to
    @objc func scrollToVerse(_ verseId: Int, searchText: String? = nil) {
        if verseId < dollar.currentChapter.verses.count {
            let verse = dollar.currentChapter.verses[verseId]
            if let row: Int = dollar.currentChapter.verses.firstIndex(of: verse) {
                let indexPath: IndexPath = IndexPath(row: row, section: 0)
                // tableView.scrollToNearestSelectedRowAtScrollPosition(UITableViewScrollPosition.Bottom, animated: true)
                tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.top, animated: false)
                if searchText != "" && searchText != nil {
                    if let cell: VerseCell  = tableView.cellForRow(at: indexPath) as? VerseCell {
                        var label: UILabel!
                        // skip highlighting arabic texts
                        if dollar.searchOption != SearchOption.searchOptionArabic {
                            if dollar.searchOption == SearchOption.searchOptionTrasliteration {
                                label = cell.transcription
                            }
                            else if dollar.searchOption == SearchOption.searchOptionTraslation {
                                label = cell.translation
                            }
                            highlightText(searchText!, inLabel: label)
                        }
                    }
                }
//                else
//                {
//                    // change background to yellow for highlight
//                    if let cell: VerseCell  = tableView.cellForRowAtIndexPath(indexPath) as? VerseCell{
//                        let view = UIView(frame: CGRectZero)
//                        view.backgroundColor = UIColor.yellowColor()
//                        cell.backgroundView = view
//                    }
//                }
            }
        }
    }
    
    // MARK: AudioDelegate
    @objc func playNextChapter() {
        if dollar.currentChapter.id < dollar.chapters.count - 1 {
            let nextChapter: Chapter = dollar.chapters[dollar.currentChapter.id  + 1]
            let audioChapter = dollar.currentReciter.audioChapters[nextChapter.id]
            dollar.setAndSaveCurrentChapter(nextChapter)
            self.title = "\(nextChapter.id + 1). \(nextChapter.name.local)"
            currentAudioChapter = dollar.currentReciter.audioChapters[dollar.currentChapter.id]
            self.currentVerseIndex = 0
            tableViewReloadData()
            scrollToVerse(currentVerseIndex, searchText: "")
            // audio of the next chapter is found, so play it
            if audioChapter.isDownloaded {
                service.play(nextChapter.verses[0])
            }
            // no audio found for the next chapter, so, notify the use
            else {
                updateControls()
                self.view.makeToast(message: "Audio not downloaded yet.".local, duration: 2, position: .top)
            }
        }
        else {
            updateControls()
        }
    }
    
    // MARK: Orientation delegate handlers
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
            coordinator.animate(alongsideTransition: nil, completion: {context in
                if !self.isScrolling && self.currentVerseIndex > 0 {
                   self.scrollToVerse(self.currentVerseIndex)
                }
        })
    }
    
    // MARK: Action sheet
    
    // Show action sheet alert
    @objc func showActionSheetAlert(_ verse: Verse, cell: VerseCell) {
        // Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
         // Create and add the Cancel action
        let cancelAction = UIAlertAction(title: "Cancel".local, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            // Just dismiss the action sheet
        })
        
        // Create play audio action
        let playAudioAction = UIAlertAction(title: "Play verse".local, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.service.setPlayVerse(verse)
            self.service.play(verse)
            self.updateControls()
            // Flurry.logEvent(FlurryEvent.playerAudioFromRow, withParameters: ["verseId" : verse.id, "chapterId": verse.chapterId])
        })
        
        // Create stop play audio action
        let stopAudioAction = UIAlertAction(title: "Stop playing".local, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.service.stopAndReset()
            self.updateControls()
            // Flurry.logEvent(FlurryEvent.stopPlayingAudioFromRow, withParameters: ["verseId" : verse.id, "chapterId": verse.chapterId])
        })
        
        // Create download audio action
        let downloadAudioAction = UIAlertAction(title: "Download chapter".local, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.downloadClickedHandler()
            // Flurry.logEvent(FlurryEvent.downloadFromRow, withParameters: ["verseId" : verse.id, "chapterId": verse.chapterId])
        })


        // Create and add the add-bookmark action
        let addBookmarkAction = UIAlertAction(title: "Add to bookmarks".local, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            BookmarkService.sharedInstance().add(verse)
            // reload the cells in order to update the bookmark icon
            self.tableViewReloadData()
            // Flurry.logEvent(FlurryEvent.addBookmark)
        })
        
        // Create and add the remove-bookmark action
        let removeBookmarkAction = UIAlertAction(title: "Remove from bookmarks".local, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            BookmarkService.sharedInstance().remove(verse)
            // reload the cells in order to update the bookmark icon
            self.tableViewReloadData()
            NotificationCenter.default.post(name: Notification.Name(rawValue: kBookmarkChangedNotification), object: nil, userInfo: nil)
            // Flurry.logEvent(FlurryEvent.removeBookmark)
        })

        var didFindVerseStart = false
        var didFindVerseEnd = false
        var startVerseId = -1
        var endVerseId = -1
        var startRepeatTitle = "Set A-B Repeat Start".local
        var endRepeatTitle = "Set A-B Repeat End".local

        for verse in dollar.currentChapter.verses {
            if ABRepeatService.sharedInstance().has(verse) {
                if !didFindVerseStart {
                    didFindVerseStart = true
                    startVerseId = verse.id
                    startRepeatTitle = "Set A-B Repeat Start (" + String(startVerseId) + ")"
                    continue
                }
                if !didFindVerseEnd && didFindVerseStart {
                    didFindVerseEnd = true
                    endVerseId = verse.id
                    endRepeatTitle = "Set A-B Repeat End (" + String(endVerseId) + ")"
                    break
                }
            }
        }

        // Create and add the add-abrepeat action
        let setABRepeatStart = UIAlertAction(title: startRepeatTitle, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            if startVerseId >= 0 {
                ABRepeatService.sharedInstance().remove(dollar.currentChapter.verses[startVerseId])
            }
            ABRepeatService.sharedInstance().add(verse)
            startVerseId = verse.id
            if verse.id > endVerseId && endVerseId >= 0 {
                ABRepeatService.sharedInstance().remove(dollar.currentChapter.verses[endVerseId])
                endVerseId = -1
            }
            self.service.stopPlaying()
            self.service.setupABRepeatPlayer()
            // NSNotificationCenter.defaultCenter().postNotificationName(kABRpeatChangedNotification, object: nil,  userInfo:nil)
            // reload the cells in order to update the bookmark icon
            // self.tableViewReloadData()
            // Flurry.logEvent(FlurryEvent.addBookmark)
        })

        // Create and add the add-abrepeat action
        let setABRepeatEnd = UIAlertAction(title: endRepeatTitle, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            if endVerseId >= 0 {
                ABRepeatService.sharedInstance().remove(dollar.currentChapter.verses[endVerseId])
                endVerseId = -1
            }
            if verse.id > startVerseId {
                ABRepeatService.sharedInstance().add(verse)
                endVerseId = verse.id
            }
            self.service.setupABRepeatPlayer()
            self.service.resetABRepeat()
            // self.service.resumePlaying()
            // NSNotificationCenter.defaultCenter().postNotificationName(kABRpeatChangedNotification, object: nil,  userInfo:nil)
            // reload the cells in order to update the bookmark icon
            // self.tableViewReloadData()
            // Flurry.logEvent(FlurryEvent.addBookmark)
        })

        // Create and add the remove-abrepeat action
        let removeABRepeat = UIAlertAction(title: "Remove A-B Repeat".local, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            ABRepeatService.sharedInstance().remove(verse)
            // reload the cells in order to update the bookmark icon
            self.tableViewReloadData()
            NotificationCenter.default.post(name: Notification.Name(rawValue: kABRepeatRemovedNotification), object: nil, userInfo: nil)
            // Flurry.logEvent(FlurryEvent.removeBookmark)
        })

        if !service.isPlaying() {
            if currentAudioChapter.isDownloaded {
                actionSheetController.addAction(playAudioAction)
            }
            else if !currentAudioChapter.isDownloading {
                actionSheetController.addAction(downloadAudioAction)
            }
        }
        else {
            actionSheetController.addAction(stopAudioAction)
        }
        
        if BookmarkService.sharedInstance().has(verse) {
            actionSheetController.addAction(removeBookmarkAction)
        }
        else {
            actionSheetController.addAction(addBookmarkAction)
        }

        if ABRepeatService.sharedInstance().has(verse) {
            actionSheetController.addAction(removeABRepeat)
            actionSheetController.addAction(setABRepeatStart)
            actionSheetController.addAction(setABRepeatEnd)
        }
        else {
            actionSheetController.addAction(setABRepeatStart)
            actionSheetController.addAction(setABRepeatEnd)
        }

        // Social media
        let shareAction =  UIAlertAction(title: "Share".local + "...", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            let activities = [(kApplicationDisplayName as String) + " - Surah " + dollar.currentChapter.name + " ayah " + String(verse.id), self.generateImage(cell), kAppUrlTemplate] as [Any]
                let ctr = UIActivityViewController(activityItems: activities, applicationActivities: nil)
            ctr.completionWithItemsHandler = { activity, success, items, error in
                if error != nil {
                    // Flurry.logError(activity.map { $0.rawValue } as! String, message: "", error: error)
                }
                else {
                    // Flurry.logEvent(activity.map { $0.rawValue } as! String, withParameters: ["success": success])
                }
            }
            ctr.excludedActivityTypes = [UIActivity.ActivityType.postToWeibo,
                // UIActivityTypeMessage,
                // UIActivityTypeMail,
                UIActivity.ActivityType.print,
                UIActivity.ActivityType.copyToPasteboard,
                UIActivity.ActivityType.assignToContact,
                UIActivity.ActivityType.saveToCameraRoll,
                UIActivity.ActivityType.addToReadingList,
                // UIActivityTypePostToFlickr,
                UIActivity.ActivityType.postToVimeo,
                UIActivity.ActivityType.postToTencentWeibo,
                UIActivity.ActivityType.airDrop]
            // We need to provide a popover sourceView when using it on iPad
            if isIpad {
                let popPresenter: UIPopoverPresentationController = ctr.popoverPresentationController!
                popPresenter.sourceView = cell;
                popPresenter.sourceRect = cell.bounds
            }
            
            // Present the AlertController
            self.present(ctr, animated: true, completion: nil)
        })
        
        // Create and add the add-bookmark action
        let copyAction = UIAlertAction(title: "Copy verse".local, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            let text = "[Surah " + dollar.currentChapter.name + " ayah " + String(verse.id) + "]\n" + cell.translation.text! + "\n" + cell.arabic.text! + "\n" + cell.transcription.text! + "\n\n\n-----\n" + (kApplicationDisplayName as String)  + "\n" + kAppUrlTemplate
            UIPasteboard.general.string = text
            // Flurry.logEvent(FlurryEvent.copy)
        })

        actionSheetController.addAction(copyAction)
        actionSheetController.addAction(shareAction)
        actionSheetController.addAction(cancelAction)
        
        // We need to provide a popover sourceView when using it on iPad
        if isIpad {
            let popPresenter: UIPopoverPresentationController = actionSheetController.popoverPresentationController!
            popPresenter.sourceView = cell;
            popPresenter.sourceRect = cell.bounds
        }
        
        // Present the AlertController
        self.present(actionSheetController, animated: true, completion: nil)
        
    }
    
    @objc func appUrl()-> String {
        let url = kAppUrlTemplate.localizeWithFormat(dollar.currentLanguageKey, kAppId)
        return url
    }
    
    // generate the image
    @objc func generateImage(_ cell: VerseCell) -> UIImage {
        let extraSpace: CGFloat = 20.0
        let text: NSString = (kApplicationDisplayName as String) + " - " + kAppUrlTemplate as NSString
        // Create the UIImage
        UIGraphicsBeginImageContextWithOptions(CGSize(width: cell.frame.size.width, height: cell.frame.size.height + extraSpace), false, 0)
        cell.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        // Save it to the camera roll
        // UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, 0);
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        let rect = CGRect(x: 0, y: image.size.height - extraSpace, width: image.size.width, height: image.size.height)
        kImageWaterMarkColor.set()
        UIRectFill(rect)
        text.draw(in: rect.integral, withAttributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): kImageWaterMarkFont]))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        
        return newImage
    }
    
    // MARK: hightlight
    
    // highlight the seach text in text view
    // see: http://www.raywenderlich.com/86205/nsregularexpression-swift-tutorial
    @objc func highlightText(_ searchText: String, inLabel label: UILabel) {
        // First, get a mutable copy of the label's attributedText.
        let attributedText = label.attributedText!.mutableCopy() as! NSMutableAttributedString
        // Then create an NSRange for the entire length of the text, and remove any background color text attributes that already exist within it.
        let attributedTextRange = NSRange(location: 0, length: attributedText.length)
        attributedText.removeAttribute(NSAttributedString.Key.backgroundColor, range: attributedTextRange)
        // As with find and replace, next create a regular expression using your convenience initializer and fetch an array of all matches for the regular expression within the label’s text.
        do {
            let regex = try NSRegularExpression(pattern: searchText, options: NSRegularExpression.Options.caseInsensitive)
            let range = NSRange(location: 0, length: (label.text!).count)
            let matches = regex.matches(in: label.text!, options: [], range: range)
            // Loop through each match (casting them as NSTextCheckingResult objects), and add a yellow colour background attribute for each one.
            for match in matches as [NSTextCheckingResult] {
                let matchRange = match.range
                
                attributedText.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.yellow, range: matchRange)
            }
        } catch _ {
        }
        // Finally, update the UITextView with the highlighted results.
        label.attributedText = attributedText.copy() as? NSAttributedString
    }
    
    // MARK: right bar item click handlers
    
    @objc func downloadClickedHandler () {
        
        func handler () {
            self.startDownload(currentAudioChapter) { () -> Void in
                self.tableView.reloadSections(IndexSet(integer: 0), with: UITableView.RowAnimation.fade)
                self.updateControls()
            }
            // Flurry.logEvent(FlurryEvent.downloadFromChapter)
        }
        if isPro {
            handler()
        }
        else {
            if currentAudioChapter.id == 0 || currentAudioChapter.id == 1 {
                handler()
            }
            else {
                self.askUserForPurchasingProVersion(FlurryEvent.downloadFromChapter)
            }
        }
    }
    
    @objc func showAudioControlsHandler () {
        service.play()
        updateControls()
    }
    
    @objc func resumeClickedHandler () {
        service.resumePlaying()
        updateControls()
    }
    
    @objc func closePlayControlClickedHandler () {
        service.stopAndReset()
        updateControls()
    }
    
    @objc func pauseClickedHandler () {
        service.pausePlaying()
        updateControls()
    }
    
    @objc func previousClickedHandler() {
        service.playPrevious()
    }
    
    @objc func nextClickedHandler() {
        service.playNext()
    }
    
    @objc func repeatClickedHandler () {
        service.repeatPlay()
        updateControls()
    }

    @objc func speedClickedHandler () {
        service.speedPlay()
        updateControls()
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
