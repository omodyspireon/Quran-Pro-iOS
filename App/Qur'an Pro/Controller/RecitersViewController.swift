//
//  RecitersViewController.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import UIKit

let recitersCellId = "recitersCellId"
class RecitersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    //keep the reference to the options
    var options: Array<Reciter>!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        overrideBackButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: recitersCellId)
        self.options = dollar.reciters
        self.title = "Select reciter".local
    }
    
    // MARK:  UITextFieldDelegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reciter: Reciter = options[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: recitersCellId, for: indexPath) as UITableViewCell
        cell.textLabel?.font = kCellTextLabelFont
        cell.textLabel?.text = reciter.name
        if isPro {
            if reciter == dollar.currentReciter {
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
            }
            else{
                cell.accessoryType = UITableViewCell.AccessoryType.none
            }
        }
        else {
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
            let reciter: Reciter = options[indexPath.row]
            dollar.currentReciter = reciter
            dollar.setPersistentObjectForKey(indexPath.row as AnyObject, key: kCurrentReciterKey)
            tableView.reloadData()
            NotificationCenter.default.post(name: Notification.Name(rawValue: kReciterChangedNotification), object: nil,  userInfo: nil)
            //Flurry.logEvent(FlurryEvent.reciterSelected, withParameters: ["value": dollar.currentReciter.name])
        }
        else if indexPath.row != 0 {
            self.askUserForPurchasingProVersion(FlurryEvent.reciterSelected)
        }
    }
}
