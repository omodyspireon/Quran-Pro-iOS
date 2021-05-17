//
//  BookmarkViewController.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import UIKit
let bookmartCellIdentifier = "BookmartCellIdentifier"

class BookmarkViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var tableView: UITableView!
    
    @objc var contents: NSMutableDictionary!
    @objc var keys: NSMutableArray!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        overrideBackButton()
    }

    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.reloadData()
        self.tableView.estimatedRowHeight = 64.0;
        self.tableView.rowHeight = UITableView.automaticDimension;
        NotificationCenter.default.addObserver(self, selector: #selector(BookmarkViewController.bookmarksChangedHandler(_:)), name:NSNotification.Name(rawValue: kBookmarkChangedNotification), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Bookmarks".local
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: bookmartCellIdentifier)
        //load the table data
        reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return keys.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (keys.object(at: section) as! String).local
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key: String = keys.object(at: section) as! String
        if let sectionContents: NSArray = self.contents.object(forKey: key) as? NSArray {
            return sectionContents.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let key: String = keys.object(at: indexPath.section) as! String
        let sectionContents: NSArray = contents.object(forKey: key) as! NSArray
        let verse: Verse = sectionContents.object(at: indexPath.row) as! Verse
        let cell = tableView.dequeueReusableCell(withIdentifier: bookmartCellIdentifier, for: indexPath) as UITableViewCell
        cell.textLabel?.text = verse.translationSearch
        cell.textLabel?.font = kLatinSearchAndBookmarkFont
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key: String = keys.object(at: indexPath.section) as! String
        let sectionContents: NSArray = contents.object(forKey: key) as! NSArray
        let verse: Verse = sectionContents.object(at: indexPath.row) as! Verse
        NotificationCenter.default.post(name: Notification.Name(rawValue: kNewVerseSelectedNotification), object: nil,  userInfo:["verse":verse, "toggle": "right"])
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    @IBAction func removeAllBookmars(_ sender: AnyObject) {
        
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Remove all bookmarks?".local, message: nil, preferredStyle: .actionSheet)
        
        //Create and add the Cancel action
        let cancelAction = UIAlertAction(title: "No".local, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            //Just dismiss the action sheet
        })
        
        //Create and add the add-bookmark action
        let removeBookmarkAction = UIAlertAction(title: "Yes".local, style: .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            BookmarkService.sharedInstance().clear()
            self.reloadData()
            NotificationCenter.default.post(name: Notification.Name(rawValue: kBookmarksRemovedNotification), object: nil,  userInfo:nil)
            //Flurry.logEvent(FlurryEvent.removeAllBookmarks)
        })
        
        actionSheetController.addAction(removeBookmarkAction)
        actionSheetController.addAction(cancelAction)
        
        //We need to provide a popover sourceView when using it on iPad
        if isIpad {
            let popPresenter: UIPopoverPresentationController = actionSheetController.popoverPresentationController!
            if let v:UIView = sender.view {
                popPresenter.sourceView = v;
                popPresenter.sourceRect = v.bounds
            }
            else{
                popPresenter.sourceView = self.view
                popPresenter.sourceRect = self.view.bounds
            }
        }
        
        //Present the AlertController
        self.present(actionSheetController, animated: true, completion: nil)
        
    }
    
    //MARK: Data
    
    @objc func reloadData(){
        let bookmarktuple = BookmarkService.sharedInstance().sortedKeysAndContents()
        self.contents = bookmarktuple.contents
        self.keys = bookmarktuple.keys
        tableView.reloadData()
        self.navigationItem.rightBarButtonItem!.isEnabled = !BookmarkService.sharedInstance().isEmpty()
        //Flurry.logEvent(FlurryEvent.totalBookmarks, withParameters: ["value": BookmarkService.sharedInstance().bookMarks.count])
    }
    
    // MARK: Notifications
    
    @objc func bookmarksChangedHandler(_ notification: Notification){
        self.reloadData()
    }
}
