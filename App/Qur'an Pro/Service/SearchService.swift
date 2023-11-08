//
//  SearchService.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

private let _SearchServiceSharedInstance = SearchService()

class SearchService {

    class func sharedInstance() -> SearchService {
        return _SearchServiceSharedInstance
    }

    // hierarchical chapters and versers
    // Get a list of keys and contents from the persistent data
    // to be used in the tableview
    func initialKeysAndContents() -> (keys: NSMutableArray, contents: NSMutableDictionary) {
        let contents: NSMutableDictionary = [:]
        let keys: NSMutableArray = []
        var key: String

        // Construct the key list with empty content
        for chapter in dollar.chapters {
            key = dollar.getKeyId(chapter)
            if contents.object(forKey: key) == nil {
                keys.add(key)
                let list = NSMutableArray()
                for verse in chapter.verses {
                    if verse.id != -1 {
                        list.add(verse)
                    }
                }
                contents.setObject(list, forKey: key as NSCopying)
            }
        }
        return (keys: keys, contents: contents)
    }

    // Get a list of keys and contents from the persistent data
    // to be used in the tableview
    func sortedKeysAndContents(_ list: NSMutableArray) -> (keys: NSMutableArray, contents: NSMutableDictionary) {
        let sortedByChapter: NSArray = list.sortedArray(using: [NSSortDescriptor(key: "chapterId", ascending: true)]) as NSArray
        let sortedByVerse: NSArray = list.sortedArray(using: [NSSortDescriptor(key: "id", ascending: true)]) as NSArray

        let contents: NSMutableDictionary = [:]
        let keys: NSMutableArray = []

        var chapter: Chapter
        var verse: Verse
        var values: NSMutableArray
        var key: String

        // Construct the key list with empty content
        for item in sortedByChapter {
            if let v: Verse = item as? Verse {
                chapter = dollar.chapters[v.chapterId]
                key = dollar.getKeyId(chapter)
                if contents.object(forKey: key) == nil {
                    keys.add(key)
                    contents.setObject(NSMutableArray(), forKey: key as NSCopying)
                }
            }
        }

        // fill in the content of the keys
        for item in sortedByVerse {
            if let v: Verse = item as? Verse {
                chapter = dollar.chapters[v.chapterId]
                key = dollar.getKeyId(chapter)
                if contents.object(forKey: key) != nil {
                    values = (contents.object(forKey: key) as? NSMutableArray)!
                    if v.chapterId == chapter.id {
                        var verseId: Int = v.id
                        if chapter.id == kFatihaIndex || chapter.id == kTaubahIndex {
                            verseId = verseId - 1
                        }
                        verse = chapter.verses[verseId]
                        values.add(verse)
                    }
                    contents.setObject(values, forKey: key as NSCopying)
                }
            }
        }
        return (keys: keys, contents: contents)
    }

}
