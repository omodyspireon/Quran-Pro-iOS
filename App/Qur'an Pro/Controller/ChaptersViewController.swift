//
//  ChaptersViewController.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import UIKit

class ChaptersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "ChaptersCell")
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "PartsCell")
        tableView.estimatedRowHeight = 64.0;
        tableView.rowHeight = UITableView.automaticDimension;

        updateLabels()
    }

    // handles the left button click action
    @objc func leftButtonClickHandler() {
        //toggle the view
        dollar.currentGroupViewType = hasChapterView() ? GroupViewType.groupPartsView : GroupViewType.groupChaptersView
        ////Flurry.logEvent(FlurryEvent.sestionSelected, withParameters: ["index": dollar.currentGroupViewType.rawValue])// fout
        updateLabels()
        //reload the list
        tableView.reloadData()
        selectRowFromSetting()
        dollar.setPersistentObjectForKey(dollar.currentGroupViewType.rawValue as AnyObject, key: kGrouViewTypeKey)
    }
    
    @objc func updateLabels() {
        self.title = hasChapterView() ? "Chapters".local :  "Ajzā’"
        
        let leftBarButtonItem: UIBarButtonItem = UIBarButtonItem(image: UIImage(named: dollar.currentGroupViewType == .groupChaptersView ?  "parts" : "chapters"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(ChaptersViewController.leftButtonClickHandler))
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    @objc func cellBackgroundColorAtIndexPath(_ indexPath: IndexPath) {
        let cell: UITableViewCell?  = tableView.cellForRow(at: indexPath)
        cell?.contentView.backgroundColor = kSelectedCellBackgroudColor
    }
    
    @objc func hasChapterView() -> Bool {
        return dollar.currentGroupViewType == .groupChaptersView
    }
    
    // MARK: Table View Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return hasChapterView() ? 1 : dollar.parts.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return hasChapterView() ? nil : "Juz'".local + "-" + "\(String(dollar.parts[section].id))"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hasChapterView() ? 114 : 8
    }

    // return list of section titles to display in section index view
//    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
//        if hasChapterView() {
//            return nil
//        }
//        else{
//            var indeces = [String]()
//            for i in 1...30 {
//                indeces.append(String(i))
//            }
//            return indeces;
//        }
//    }
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = hasChapterView() ? "Chapters" : "Parts"

        var cell = tableView.dequeueReusableCell(withIdentifier: "\(cellId)Cell")
        if cell != nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "\(cellId)Cell")
        }
        if hasChapterView(){
            let chapter: Chapter = dollar.chapters[indexPath.row] as Chapter
            cell?.imageView!.image = UIImage(named: "sn\(chapter.id + 1)")
            cell?.textLabel!.text = "\(chapter.id + 1). \(chapter.name.local)"
            cell?.textLabel!.font = kCellTextLabelFont
            cell?.textLabel!.textColor = kCellTextLabelColor
            var verses = chapter.verses.count
            if (chapter.id != kTaubahIndex) && (chapter.id != kFatihaIndex) {
                verses -= 1
            }
            cell?.detailTextLabel?.text = chapter.revelationLocation + " - \(verses) ayāt"
            cell?.detailTextLabel?.textColor = kCellTextLabelColor
        }
        else{
            let part: Part = dollar.parts[indexPath.section] as Part
            let partQuarter = part.partQuarters[indexPath.row]
            let chapter: Chapter = dollar.chapters[partQuarter.chapterId - 1] as Chapter
            var verseId = partQuarter.verseId
            if (partQuarter.chapterId - 1 == kFatihaIndex) || (partQuarter.chapterId - 1 == kTaubahIndex) {
                verseId -= 1
            }
            let verse: Verse = chapter.verses[verseId]
            cell?.imageView!.image = nil
            let numbers = "\(verse.chapterId + 1):\(verse.id) "
            cell?.textLabel!.text = numbers + verse.translation
            cell?.textLabel!.font = kLatinSearchAndBookmarkFont
            cell?.detailTextLabel?.text = partQuarter.display()
            cell?.detailTextLabel?.textColor = kCellTextLabelColor
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kHeightForRowAtIndexPath
    }
    
    // Mark: Table View Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if hasChapterView() {
            cellBackgroundColorAtIndexPath(indexPath)
            let chapter: Chapter = dollar.chapters[indexPath.row] as Chapter
            dollar.setAndSaveCurrentChapter(chapter)
            NotificationCenter.default.post(name: Notification.Name(rawValue: kNewChapterSelectedNotification), object: nil,  userInfo:["chapter": chapter])
            //Flurry.logEvent(FlurryEvent.chapterSelected, withParameters: ["chapter": chapter.description])
        }
        else{
            let part: Part = dollar.parts[indexPath.section] as Part
            let partQuarter = part.partQuarters[indexPath.row]
            let chapter: Chapter = dollar.chapters[partQuarter.chapterId - 1] as Chapter
            var verseId = partQuarter.verseId
            if (partQuarter.chapterId - 1 == kFatihaIndex) || (partQuarter.chapterId - 1 == kTaubahIndex) {
                verseId -= 1
            }
            let verse: Verse = chapter.verses[verseId]
            NotificationCenter.default.post(name: Notification.Name(rawValue: kNewVerseSelectedNotification), object: nil,  userInfo:["verse":verse, "verseReady":true, "toggle": "left"])
            //Flurry.logEvent(FlurryEvent.verseViaSectionSelected, withParameters: ["verse": verse.description])
        }
        cellBackgroundColorAtIndexPath(indexPath)
    }
    
    // scroll the current chanpter and sets the bg color
    @objc func selectRowFromSetting() {
        if hasChapterView() {
            if let row: Int = dollar.chapters.index(of: dollar.currentChapter) {
                let indexPath: IndexPath = IndexPath(row: row, section: 0)
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableView.ScrollPosition.top)
                cellBackgroundColorAtIndexPath(indexPath)
            }
        }
    }
}
