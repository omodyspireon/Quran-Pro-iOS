//
//  SearchOptionViewController.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import UIKit
let searchOptionCellId = "SearchOptionCell"
class SearchOptionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    //keep the reference to the options
    @objc var options: Array<String>!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        overrideBackButton()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: searchOptionCellId)
        self.options = ["Search in translation".local, "Search in Arabic".local, "Search in transliteration".local]
        self.title = "Search options".local
    }
    
    // MARK:  UITextFieldDelegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: searchOptionCellId, for: indexPath) as UITableViewCell
        cell.textLabel?.font = kCellTextLabelFont
        cell.textLabel?.text = options[indexPath.row]
        if isPro {
            if indexPath.row != dollar.searchOption.rawValue {
                cell.accessoryType = UITableViewCell.AccessoryType.none
            }
            else{
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
            }
        }
        else{
            if indexPath.row == 0 {
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
            }
            else{
                cell.lock()
            }
        }
        return cell
    }
    
    // MARK:  UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isPro {
            dollar.searchOption = SearchOption(rawValue: indexPath.row)!
            dollar.setPersistentObjectForKey(indexPath.row as AnyObject, key: kCurrentSearchOptionKey)
            tableView.reloadData()
            NotificationCenter.default.post(name: Notification.Name(rawValue: kSearchOptionChangedNotification), object: nil,  userInfo: nil)
            //Flurry.logEvent(FlurryEvent.searchOption, withParameters: ["value": dollar.searchOption.rawValue])
        }
        else if indexPath.row != 0 {
            self.askUserForPurchasingProVersion(FlurryEvent.searchOption)
        }
    }
}
