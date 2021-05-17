//
//  ChapterPlayOptionViewController.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import UIKit

let chapterPlayOptionCellId = "chapterPlayOptionCellId"
class ChapterPlayOptionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
 
    @objc var service: AudioService = AudioService.sharedInstance()
    @IBOutlet var tableView: UITableView!

    @objc var contents: NSMutableDictionary!
    @objc var keys: NSArray!
    
    //keep the reference to the options
    @objc var options: Array<String>!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        overrideBackButton()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: chapterPlayOptionCellId)
        self.options = service.repeats.chapters
        createData()
        self.title = "Chapter play options".local
    }

    // MARK: intiate the data
    @objc func createData (){

        //keys:
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


    // MARK:  UITextFieldDelegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: chapterPlayOptionCellId, for: indexPath) as UITableViewCell
        cell.textLabel?.font = kCellTextLabelFont
        cell.textLabel?.text = options[indexPath.row]
        if isPro {
            if service.repeats.chapterCount == indexPath.row {
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
            }
            else{
                cell.accessoryType = UITableViewCell.AccessoryType.none
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
            service.repeats.chapterCount = indexPath.row
            dollar.setPersistentObjectForKey(indexPath.row as AnyObject, key: kCurrentRepeatChapterhKey)
            tableView.reloadData()
            //Flurry.logEvent(FlurryEvent.chapterPlayOption, withParameters: ["value": indexPath.row])
        }
        else if indexPath.row != 0 {
            self.askUserForPurchasingProVersion(FlurryEvent.chapterPlayOption)
        }
    }
}
