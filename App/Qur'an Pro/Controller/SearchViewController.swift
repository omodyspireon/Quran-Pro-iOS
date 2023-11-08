//
//  SearchViewController.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import UIKit

let searchCellId = "SearchCellId"

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchResultsUpdating {

    @IBOutlet weak var tableView: UITableView!
    @objc var searchController: UISearchController!
    let service: SearchService = SearchService.sharedInstance()

    // keep the reference to the options
    @objc var contents: NSMutableDictionary!
    @objc var keys: NSMutableArray!
    @objc var searchContents: NSMutableDictionary!
    @objc var searchKeys: NSMutableArray!
    @objc var resultPredicate: NSPredicate?
    @objc var searchQueue: OperationQueue!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        overrideBackButton()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.searchQueue = OperationQueue()
        self.searchQueue.maxConcurrentOperationCount = 1

        let tuple = service.initialKeysAndContents()
        contents = tuple.contents
        keys = tuple.keys

        // init the search values
        searchContents = tuple.contents
        searchKeys = tuple.keys

        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: searchCellId)

        // init the seach controller
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.searchBarStyle = UISearchBar.Style.default
        searchController.searchBar.placeholder = "e.g. 6:88, الله, hizb 8 or Allah".local
        // tableView.tableHeaderView = searchController.searchBar
        navigationItem.titleView = searchController.searchBar

        // self.tableView.sectionIndexTrackingBackgroundColor = kAppColor
        // self.tableView.sectionIndexBackgroundColor = kAppColorLight
        // tableView.sectionIndexColor = kAppColor

        // By default the navigation bar hides when presenting the
        // search interface.  Obviously we don't want this to happen if
        // our search bar is inside the navigation bar.
        searchController.hidesNavigationBarDuringPresentation = false

        self.definesPresentationContext = true

        // The search bar does not seem to set its size automatically
        // which causes it to have zero height when there is no scope
        // bar. If you remove the scopeButtonTitles above and the
        // search bar is no longer visible make sure you force the
        // search bar to size itself (make sure you do this after
        // you add it to the view hierarchy).
        self.searchController.searchBar.sizeToFit()

        // style the searchdisplay contoller
        searchController.searchBar.setBackgroundImage(UIImage(named: kUINavigationBarBackgroundImage), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        // Sets the cancel text color to white
        // UIBarButtonItem.appearance().tintColor = UIColor.blackColor()

        let searchBarView: UIView = searchController.searchBar.subviews[0] as UIView
        // set the blinking cursor for the search field
        for subView: UIView in searchBarView.subviews {
            if subView.isKind(of: UITextField.self) {
                subView.tintColor = kAppColor
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(SearchViewController.searchOptionChangedHandler(_:)), name: NSNotification.Name(rawValue: kSearchOptionChangedNotification), object: nil)

        if dollar.searchOption != SearchOption.searchOptionArabic {
            self.tableView.estimatedRowHeight = 64.0
            self.tableView.rowHeight = UITableView.automaticDimension
        }
    }

    // MARK: UITextFieldDelegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.searchController.isActive {
            return searchKeys.count
        } else {
            return keys.count
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.searchController.isActive {
            return (searchKeys.object(at: section) as! String)
        } else {
            return (keys.object(at: section) as! String)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchController.isActive {
            let key: String = searchKeys.object(at: section) as! String
            if let sectionContents: NSArray = self.searchContents.object(forKey: key) as? NSArray {
                return sectionContents.count
            }
        } else {
            let key: String = keys.object(at: section) as! String
            if let sectionContents: NSArray = self.contents.object(forKey: key) as? NSArray {
                return sectionContents.count
            }
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: searchCellId, for: indexPath) as UITableViewCell
        var verse: Verse
        var key: String
        var sectionContents: NSArray
        if self.searchController.isActive {
            key = searchKeys.object(at: indexPath.section) as! String
            sectionContents = searchContents.object(forKey: key) as! NSArray
        } else {
            key = keys.object(at: indexPath.section) as! String
            sectionContents = contents.object(forKey: key) as! NSArray
        }

        verse = sectionContents.object(at: indexPath.row) as! Verse
        if dollar.searchOption == SearchOption.searchOptionArabic {
            cell.textLabel?.text = verse.nonVocalArabicSearch
        } else if dollar.searchOption == SearchOption.searchOptionTraslation {
            cell.textLabel?.text = verse.translationSearch
        } else if dollar.searchOption == SearchOption.searchOptionTrasliteration {
            cell.textLabel?.text = verse.transcriptionSearch
        }
        if dollar.searchOption == SearchOption.searchOptionArabic {
            if dollar.arabicFont == ArabicFontType.useMEQuranicFont {
                cell.textLabel?.font = kMEArabicSearchFont
            } else if dollar.arabicFont == ArabicFontType.usePDMSQuranicFont {
                cell.textLabel?.font = kPDMSArabicSearchFont
            } else {
                cell.textLabel?.font = kPDMSArabicSearchFont
            }
        } else {
            cell.textLabel?.font = kLatinSearchAndBookmarkFont
        }
        return cell
    }

    /*func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        if !self.searchController.active {
            let indeces: NSMutableArray = NSMutableArray(array: [])
            for i in 1...114 {
                indeces.addObject("\(i)")
            }
            return indeces as [AnyObject];
        }
        return nil;
    }*/

    // MARK: UITableViewDelegate Metoverride hods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var sectionContents: NSArray
        var key: String
        var verse: Verse
        if self.searchController.isActive {
            key = searchKeys.object(at: indexPath.section) as! String
            sectionContents = searchContents.object(forKey: key) as! NSArray
        } else {
            key = keys.object(at: indexPath.section) as! String
            sectionContents = contents.object(forKey: key) as! NSArray
        }

        verse = sectionContents.object(at: indexPath.row) as! Verse

        var notDict = [String: NSObject]()
        notDict["verse"] = verse
        notDict["toggle"] = "right" as NSObject

        if let text = searchController.searchBar.text {
            notDict["searchText"] = text as NSObject
        }

        NotificationCenter.default.post(name: Notification.Name(rawValue: kNewVerseSelectedNotification), object: nil, userInfo: notDict as [AnyHashable: Any])
        tableView.deselectRow(at: indexPath, animated: false)
    }

    // MARK: Notifications
    @objc func searchOptionChangedHandler(_ notification: Notification) {

    }

    // MARK: UISearchBarDelegate
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchQueue.cancelAllOperations()
    }

    // MARK: UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        let searchText: String = searchController.searchBar.text!
        if searchText == "" {
            return
        }

        self.searchQueue.cancelAllOperations()

        // defines in which property will be searched
        var searchAttribute: String = "translationSearch" // default
        if dollar.searchOption == SearchOption.searchOptionArabic {
            searchAttribute = "nonVocalArabicSearch"
        } else if dollar.searchOption == SearchOption.searchOptionTrasliteration {
            searchAttribute = "transcriptionSearch"
        }

        // create the predicate format, the typed query should be
        // contained in the searchAttribute on the verse instance
        let predicateFormat: String = "%K contains[c] %@"
        let predicate: NSPredicate = NSPredicate(format: predicateFormat, searchAttribute, searchText)

        // grap a copy of the verses as a NSArray
        let verses = dollar.verses as NSArray

        // see: https://deeperdesign.wordpress.com/2011/05/30/cancellable-asynchronous-searching-with-uisearchdisplaycontroller/
        self.searchQueue.addOperation { () -> Void in
            OperationQueue.main.addOperation { () -> Void in
                // apply the predicate to search for the verses containing the query
                let searchVesers: NSArray = verses.filtered(using: predicate) as NSArray
                if searchVesers.count == 0 {
                    self.view.makeToast(message: "No results".local, duration: 2, position: .top)
                    self.searchContents = NSMutableDictionary()
                    self.searchKeys = NSMutableArray()
                } else {
                    // gets the hierarchical representation of the filtred versers
                    let tuple = self.service.sortedKeysAndContents(NSMutableArray(array: searchVesers))
                    self.searchContents = tuple.contents
                    self.searchKeys = tuple.keys
                    // FIXME: Fix this later.
//                    if let existToast = objc_getAssociatedObject(self.view, &HRToastView) as? UIView {
//                        self.view.hideToast(toast: existToast, force: true)
//                    }
                }
                self.tableView.reloadData()
                // Flurry.logEvent(FlurryEvent.searchQuery, withParameters: ["value": searchText])
            }
        }
    }
}
