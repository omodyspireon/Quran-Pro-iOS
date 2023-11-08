//
//  MoreViewController.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import UIKit
import MessageUI

class MoreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var goProButton: UIButton!

    @objc var settings: NSDictionary!
    @objc var keys: NSArray!
    @objc var footerView: UILabel?

    @objc var tellAFriendMail: MFMailComposeViewController?
    @objc var contactUsdMail: MFMailComposeViewController?

    @IBAction func goProButtonTouched(_ sender: AnyObject) {
        self.askUserForPurchasingProVersion("BuyQuranProButton")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "More".local

        // load the table data
        createData()
        tableView.reloadData()
    }

    // override the blue section style defined n the extension
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isPro {
            return nil
        } else {
            if section == 0 {
                let cellIdentifier = "ProSectionHeader"
                let headerView = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
                return headerView
            } else {
                return nil
            }
        }
    }

    // MARK: intiate the data
    @objc func createData () {

        // keys:
        let key1: String = "Actions".local
        let key2: String = "Settings".local
        let key3: String = "More".local

        // Settings
        let key1Content = [
            Setting(name: "Search".local, imageName: "search", type: SettingType.settingTypeSearch),
            Setting(name: "Bookmarks".local, imageName: "bookmark", type: SettingType.settingTypeBookmark),
            Setting(name: "Audio Downloads".local, imageName: "download_cloud_small", type: SettingType.settingTypeAudioDownload)
        ]

        let key2Content = [
            Setting(name: "Select translation".local, imageName: "geography", type: SettingType.settingTypeTranslation),
            Setting(name: "Select reciter".local, imageName: "recitator", type: SettingType.settingTypeRecitator),
            Setting(name: "Search options".local, imageName: "search_setting", type: SettingType.settingTypeSearchOption),
            Setting(name: "Verse play options".local, imageName: "ayah_play_option", type: SettingType.settingTypeVersePlayOption),
            Setting(name: "Chapter play options".local, imageName: "surah_play_option", type: SettingType.settingTypeChapterPlayOption),
            Setting(name: "Chapter view options".local, imageName: "surah_view_option", type: SettingType.settingTypeChapterViewOption)
        ]
        let key3Content = [
            Setting(name: "Tell a friend".local, imageName: "tell_a_friend", type: SettingType.settingTypeTellAFriend),
            Setting(name: "Write a review".local, imageName: "write_a_review", type: SettingType.settingTypeAppReview),
            // Setting(name: "Islamic apps".local, imageName: "islamic_apps", type: SettingType.SettingTypeIslamicApps),
            Setting(name: "Contact us".local, imageName: "contact_us", type: SettingType.settingTypeContactUs)
        ]

        self.keys = isPro ? [key1, key2, key3] : ["_", key1, key2, key3]
        self.settings = isPro ? [key1: key1Content, key2: key2Content, key3: key3Content] : ["_": [], key1: key1Content, key2: key2Content, key3: key3Content]
    }

    // MARK: Table View Data Source

    func numberOfSections(in tableView: UITableView) -> Int {
        return keys.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (keys.object(at: section) as! String).local
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key: String = keys.object(at: section) as! String
        if let sectionSettings: NSArray = self.settings.object(forKey: key) as? NSArray {
            return sectionSettings.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let key: String = keys.object(at: indexPath.section) as! String
        let sectionSettings: NSArray = settings.object(forKey: key) as! NSArray
        let setting: Setting = sectionSettings.object(at: indexPath.row) as! Setting

        let cellIdentifier = "MoreCellIdentifier"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as UITableViewCell
        cell.textLabel?.text = setting.name
        cell.textLabel?.font = kCellTextLabelFont
        cell.imageView?.image = setting.icon
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key: String = keys.object(at: indexPath.section) as! String
        let sectionSettings: NSArray = settings.object(forKey: key) as! NSArray
        let setting: Setting = sectionSettings.object(at: indexPath.row) as! Setting

        var viewController: UIViewController!
        if setting.type == SettingType.settingTypeBookmark {
            viewController = UIStoryboard.bookMarkViewController()
        } else if setting.type == SettingType.settingTypeAudioDownload {
            viewController = UIStoryboard.downloadViewController()
        }
            // options
        else if setting.type == SettingType.settingTypeSearchOption {
            viewController = UIStoryboard.searchOptionsViewController()
        } else if setting.type == SettingType.settingTypeRecitator {
            viewController = UIStoryboard.recitersViewController()
        } else if setting.type == SettingType.settingTypeVersePlayOption {
            viewController = UIStoryboard.versePlayOptionViewController()
        } else if setting.type == SettingType.settingTypeChapterPlayOption {
            viewController = UIStoryboard.chapterPlayOptionViewController()
        } else if setting.type == SettingType.settingTypeChapterViewOption {
            viewController = UIStoryboard.chapterViewOptionViewController()
        } else if setting.type == SettingType.settingTypeSearch {
            viewController = UIStoryboard.searchViewController()
        } else if setting.type == SettingType.settingTypeTranslation {
            viewController = UIStoryboard.translationViewController()
        } else if setting.type == SettingType.settingTypeTellAFriend {
            if MFMailComposeViewController.canSendMail() {
                tellAFriendMail = MFMailComposeViewController()
                tellAFriendMail!.mailComposeDelegate = self
                tellAFriendMail!.setSubject("Tell a friend subject".local)
                let message = "Tell a friend message".local
                tellAFriendMail!.setMessageBody(message.localizeWithFormat(dollar.currentLanguageKey, kAppId), isHTML: true)
                self.present(tellAFriendMail!, animated: true, completion: nil)
            }
        } else if setting.type == SettingType.settingTypeContactUs {
            if MFMailComposeViewController.canSendMail() {
                contactUsdMail = MFMailComposeViewController()
                contactUsdMail!.mailComposeDelegate = self
                contactUsdMail!.setSubject("Contact us".local)
                contactUsdMail!.setToRecipients([kDevEmail])
                self.present(contactUsdMail!, animated: true, completion: nil)
            }
        } else if setting.type == SettingType.settingTypeAppReview {
            // Flurry.logEvent(FlurryEvent.writeAReview)
            let appUrl = kReviewUrl.localizeWithFormat(kAppId)
            UIApplication.shared.openURL(URL(string: appUrl)!)
        } else if setting.type == SettingType.settingTypeIslamicApps {
            // Flurry.logEvent(FlurryEvent.islamicApps)
            UIApplication.shared.openURL(URL(string: kMoreAppsUrl)!)
        }

        if viewController != nil {
            self.navigationContoller().pushViewController(viewController, animated: true)
        }

        tableView.deselectRow(at: indexPath, animated: false)
    }

    @objc func navigationContoller() -> UINavigationController {
        return self.parent as! UINavigationController
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let key: String = keys.object(at: section) as! String
        let current = keys[keys.count - 1] as! String
        if current as String == key {
            if footerView == nil {
                 footerView = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
            }

            let appName = kApplicationDisplayName
            let dev = "by @adilbenmoussa".local
            footerView!.text = "\(appName) - v\(kApplicationVersion) \n \(dev)"
            footerView!.lineBreakMode = .byWordWrapping
            footerView!.numberOfLines = 0
            footerView!.textAlignment = NSTextAlignment.center
            footerView!.font = kMoreTableFooterFont
            footerView!.textColor = UIColor.black
            return footerView
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let key: String = keys.object(at: section) as! String
        let current = keys[keys.count - 1] as! String
        if current as String == key {
            return 80.0
        }
        // use the default one
        return 0
    }

    // MARK: MFMailComposeViewController delegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
//        if  controller == tellAFriendMail {
//            switch result.rawValue {
//            case MFMailComposeResult.cancelled.rawValue:
//                //Flurry.logEvent(FlurryEvent.tellAfriendMailCancelled)
//            case MFMailComposeResult.saved.rawValue:
//                //Flurry.logEvent(FlurryEvent.tellAfriendSaved)
//            case MFMailComposeResult.sent.rawValue:
//                //Flurry.logEvent(FlurryEvent.tellAfriendMailSent)
//            case MFMailComposeResult.failed.rawValue:
//                //Flurry.logError(FlurryEvent.tellAfriendMailFaild, message: error!.localizedDescription, error: error)
//            default:
//                break
//            }
//        }
        self.dismiss(animated: false, completion: nil)
    }

}
