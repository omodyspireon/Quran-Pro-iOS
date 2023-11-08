//
//  TranslationViewController.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import Foundation

let translationCellId = "translationCellId"

class TranslationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        overrideBackButton()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: translationCellId)
        self.title = "Select translation".local
    }

    // MARK: UITextFieldDelegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dollar.translations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: translationCellId, for: indexPath) as UITableViewCell
        let translation = dollar.translations[indexPath.row]
        cell.textLabel?.font = kCellTextLabelFont
        cell.textLabel?.text = translation.name
        cell.imageView?.image = translation.icon
        if isPro {
            if dollar.currentLanguageKey == translation.id {
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
            } else {
                cell.accessoryType = UITableViewCell.AccessoryType.none
            }
        } else {
            if dollar.currentLanguageKey == translation.id {
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                cell.unlock()
            } else {
                cell.lock()
            }
        }
        return cell
    }

    // MARK: UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let translation = dollar.translations[indexPath.row]
        if isPro {
            dollar.currentLanguageKey = translation.id
            dollar.setPersistentObjectForKey(translation.id as AnyObject, key: kCurrentTranslationKey)
            tableView.reloadData()
            dollar.updateContent()
            // Flurry.logEvent(FlurryEvent.translationSelected, withParameters: ["name": translation.name])
        } else if dollar.currentLanguageKey != translation.id {
            self.askUserForPurchasingProVersion(FlurryEvent.translationSelected)
        }
    }
}
