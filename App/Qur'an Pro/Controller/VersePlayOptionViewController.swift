//
//  VersePlayOptionViewController.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import UIKit

let versePlayOptionCellId = "versePlayOptionCellId"
class VersePlayOptionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @objc var service: AudioService = AudioService.sharedInstance()
    @IBOutlet var tableView: UITableView!

    // keep the reference to the options
    @objc var options: Array<String>!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        overrideBackButton()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: versePlayOptionCellId)
        self.options = service.repeats.verses
        self.title = "Verse play options".local

        NotificationCenter.default.addObserver(self, selector: #selector(VersePlayOptionViewController.repatCoutChangedHandler(_:)), name: NSNotification.Name(rawValue: kRepatCountChangedNotification), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(VersePlayOptionViewController.speedCountChangedHandler(_:)), name: NSNotification.Name(rawValue: kSpeedCountChangeNotification), object: nil)
    }

    @objc func repatCoutChangedHandler (_ notification: Notification) {
        self.tableView.reloadData()
    }

    @objc func speedCountChangedHandler (_ notification: Notification) {
        self.tableView.reloadData()
    }

    // MARK: UITextFieldDelegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: versePlayOptionCellId, for: indexPath) as UITableViewCell
        cell.textLabel?.font = kCellTextLabelFont
        cell.textLabel?.text = options[indexPath.row]
        if isPro {
            if (service.repeats.verseCount == indexPath.row) || (service.repeats.verses.count-1 ==  indexPath.row && service.repeats.verseCount == -1) {
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
            } else {
                cell.accessoryType = UITableViewCell.AccessoryType.none
            }
        } else {
            if indexPath.row == 0 {
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
            } else {
                cell.lock()
            }
        }
        return cell
    }

    // MARK: UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isPro {
            let index = indexPath.row == service.repeats.verses.count-1 ? -1 : indexPath.row
            service.repeats.verseCount = index
            dollar.setPersistentObjectForKey(index as AnyObject, key: kCurrentRepeatVerseKey)
            tableView.reloadData()
            // Flurry.logEvent(FlurryEvent.versePlayOption, withParameters: ["value": index])
        } else if indexPath.row != 0 {
            self.askUserForPurchasingProVersion(FlurryEvent.versePlayOption)
        }
    }
}
