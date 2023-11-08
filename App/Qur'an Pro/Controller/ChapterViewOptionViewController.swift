//
//  ChapterViewOptionViewController.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import UIKit

let chapterViewOptionCellId = "chapterViewOptionCellId"
class VerseViewClass {
    var name: String!
    var type: VerseViewType!
    var value: Int!
    init(name: String, type: VerseViewType, value: Int) {
        self.name = name
        self.type = type
        self.value = value

    }
}

class ArabicFont {
    var name: String!
    var type: ArabicFontType!
    init(name: String, type: ArabicFontType) {
        self.name = name
        self.type = type
    }
}

class FontSizeClass {
    var name: String!
    var type: FontSizeType!
    init(name: String, type: FontSizeType) {
        self.name = name
        self.type = type
    }
}

class ChapterViewOptionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var tableView: UITableView!

    @objc var contents: NSMutableDictionary!
    @objc var keys: NSArray!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        overrideBackButton()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Chapter view options".local
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: chapterViewOptionCellId)
        // load the table data
        createData()
        tableView.reloadData()
    }

    // MARK: intiate the data
    @objc func createData () {

        // keys:
        let key1: String = "Verse view".local
        let key2: String = "Arabic font".local
        let key3: String = "Font size".local

        // Settings
        let key1Content = [
            VerseViewClass(name: "No Translation".local, type: VerseViewType.noTranslation, value: dollar.showTranslation ? 0 : 1),
            VerseViewClass(name: "No Transliteration".local, type: VerseViewType.noTransliteration, value: dollar.showTransliteration ? 0 : 1)
        ]

        let key2Content = [
            ArabicFont(name: "Use ME Quranic font".local, type: ArabicFontType.useMEQuranicFont),
            ArabicFont(name: "Use PDMS Quranic font".local, type: ArabicFontType.usePDMSQuranicFont),
            ArabicFont(name: "Use Normal Arabic font".local, type: ArabicFontType.useNormalArabicFont)
        ]

        let key3Content = [
            FontSizeClass(name: "Medium".local, type: FontSizeType.medium),
            FontSizeClass(name: "Large".local, type: FontSizeType.large),
            FontSizeClass(name: "Extra Large".local, type: FontSizeType.extraLarge)
        ]

        self.keys = [key1, key2, key3]
        self.contents = [key1: key1Content, key2: key2Content, key3: key3Content]
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
        if let sectionContents: NSArray = self.contents.object(forKey: key) as? NSArray {
            return sectionContents.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let key: String = keys.object(at: indexPath.section) as! String
        let sectionContents: NSArray = contents.object(forKey: key) as! NSArray

        let cell = tableView.dequeueReusableCell(withIdentifier: chapterViewOptionCellId, for: indexPath) as UITableViewCell
        if let verseView: VerseViewClass = sectionContents.object(at: indexPath.row) as? VerseViewClass {
            if verseView.type == VerseViewType.noTranslation {
                cell.accessoryType = dollar.showTranslation ? UITableViewCell.AccessoryType.none :  UITableViewCell.AccessoryType.checkmark
            } else if verseView.type == VerseViewType.noTransliteration {
                cell.accessoryType = dollar.showTransliteration ? UITableViewCell.AccessoryType.none :  UITableViewCell.AccessoryType.checkmark
            }
            cell.textLabel?.text = verseView.name
        } else if let arabicFont: ArabicFont = sectionContents.object(at: indexPath.row) as? ArabicFont {
            // cell.accessoryType = dollar.useQuranicFont ? UITableViewCellAccessoryType.Checkmark :  UITableViewCellAccessoryType.None
            if arabicFont.type == ArabicFontType.useMEQuranicFont {
                cell.accessoryType = dollar.arabicFont == ArabicFontType.useMEQuranicFont ? UITableViewCell.AccessoryType.checkmark :  UITableViewCell.AccessoryType.none
                cell.textLabel?.font = kMEArabicSearchFont
            } else if arabicFont.type == ArabicFontType.usePDMSQuranicFont {
                cell.accessoryType = dollar.arabicFont == ArabicFontType.usePDMSQuranicFont ? UITableViewCell.AccessoryType.checkmark :  UITableViewCell.AccessoryType.none
                cell.textLabel?.font = kPDMSArabicSearchFont
            } else if arabicFont.type == ArabicFontType.useNormalArabicFont {
                cell.accessoryType = dollar.arabicFont == ArabicFontType.useNormalArabicFont ? UITableViewCell.AccessoryType.checkmark :  UITableViewCell.AccessoryType.none
                cell.textLabel?.font = kLatinFont
            }
            cell.textLabel?.text = arabicFont.name
        } else if let fontSize: FontSizeClass = sectionContents.object(at: indexPath.row) as? FontSizeClass {
            if fontSize.type == FontSizeType.medium {
                cell.accessoryType = dollar.fontLevel == FontSizeType.medium ? UITableViewCell.AccessoryType.checkmark :  UITableViewCell.AccessoryType.none
                cell.textLabel?.font = kLatinFont
            } else if fontSize.type == FontSizeType.large {
                cell.accessoryType = dollar.fontLevel == FontSizeType.large ? UITableViewCell.AccessoryType.checkmark :  UITableViewCell.AccessoryType.none
                cell.textLabel?.font = kLatinFontLarge
            } else if fontSize.type == FontSizeType.extraLarge {
                cell.accessoryType = dollar.fontLevel == FontSizeType.extraLarge ? UITableViewCell.AccessoryType.checkmark :  UITableViewCell.AccessoryType.none
                cell.textLabel?.font = kLatinFontExtraLarge
            }
            cell.textLabel?.text = fontSize.name
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key: String = keys.object(at: indexPath.section) as! String
        let sectionContents: NSArray = contents.object(forKey: key) as! NSArray
        var keyToSet: String!
        var value: AnyObject!
        if let verseView: VerseViewClass = sectionContents.object(at: indexPath.row) as? VerseViewClass {
            if verseView.type == VerseViewType.noTranslation {
                dollar.showTranslation = !dollar.showTranslation
                keyToSet = kShowTranslationKey
                value = dollar.showTranslation  ? 1  as AnyObject: 0 as AnyObject
            } else if verseView.type == VerseViewType.noTransliteration {
                dollar.showTransliteration = !dollar.showTransliteration
                keyToSet = kShowTransliterationKey
                value = dollar.showTransliteration ? 1  as AnyObject: 0 as AnyObject
            }
        } else if let arabicFont: ArabicFont = sectionContents.object(at: indexPath.row) as? ArabicFont {
            dollar.arabicFont = arabicFont.type
            keyToSet = kCurrentArabicFontKey
            value = arabicFont.type.rawValue as AnyObject
        } else if let fontSize: FontSizeClass = sectionContents.object(at: indexPath.row) as? FontSizeClass {
            dollar.fontLevel = fontSize.type
            keyToSet = kCurrentFontLevelKey
            value = fontSize.type.rawValue as AnyObject
        }

        dollar.setPersistentObjectForKey(value, key: keyToSet)
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: false)
                NotificationCenter.default.post(name: Notification.Name(rawValue: kViewChangedNotification), object: nil, userInfo: nil)
        // Flurry.logEvent(FlurryEvent.chapterViewOption, withParameters: ["key": keyToSet, "value": value])
    }
}
