//
//  BookmarkService.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

private let _ABRepeatServiceSharedInstance = ABRepeatService()

class ABRepeatService {

    class func sharedInstance() -> ABRepeatService {
        return _ABRepeatServiceSharedInstance
    }
    
    //keep a reference to the bookmarks
    var bookMarks: NSMutableArray!;

    init() {
        self.load()
    }

    //Load the persitent bookmarks
    fileprivate func load(){
        // Loads the bookmarks
        if let bookMarksData = Bundle.readArrayPlistFromDocumentFolder(kABRepeatFile) {
            bookMarks = bookMarksData.mutableCopy() as! NSMutableArray
        }
        // No bookmarkt found yet, so create a new empty file
        else{
            bookMarks = NSMutableArray()
            Bundle.writeArrayPlistToDocumentFolder(filename: kABRepeatFile, array: self.bookMarks)
        }
    }
    
    //Check the passed wheter the passed verse is bookmarked or not
    func has(_ verse: Verse) -> Bool {
        if(bookMarks != nil) {
            for bookmark in bookMarks {
                if let kBookmark  = bookmark as? NSDictionary {
                    if (kBookmark.object(forKey: kChapterhId) as? Int == verse.chapterId) && (kBookmark.object(forKey: kVerseId) as? Int == verse.id) {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    //Remove the passed verse from the bookmark
    func remove(_ verse: Verse){
        var dirty = false
        for bookmark in bookMarks {
            if let kBookmark  = bookmark as? NSDictionary {
                if (kBookmark.object(forKey: kChapterhId) as? Int == verse.chapterId) && (kBookmark.object(forKey: kVerseId) as? Int == verse.id) {
                    bookMarks.remove(bookmark)
                    dirty = true
                    break
                }
            }
        }
        
        if dirty {
            Bundle.writeArrayPlistToDocumentFolder(filename: kABRepeatFile, array: bookMarks)
        }
    }
    
    //Add the passed verse from the bookmark
    func add(_ verse: Verse){
        bookMarks.add([kChapterhId: verse.chapterId, kVerseId: verse.id])
        Bundle.writeArrayPlistToDocumentFolder(filename: kABRepeatFile, array: bookMarks)
    }
    
    //Remove all bookmarks
    func clear() {
        bookMarks = NSMutableArray()
        Bundle.writeArrayPlistToDocumentFolder(filename: kABRepeatFile, array: bookMarks)
    }
    
    //Check if the bookmark list is empty
    func isEmpty () -> Bool{
        return bookMarks.count == 0
    }
    
    
    //Get a list of keys and contents from the persistent data
    // to be used in the tableview
    func sortedKeysAndContents() -> (keys: NSMutableArray, contents: NSMutableDictionary){
        let sortedBookmarksByChapter: NSArray = bookMarks.sortedArray(using: [NSSortDescriptor(key: kChapterhId, ascending: true)]) as NSArray
        let sortedBookmarksByVerse: NSArray = bookMarks.sortedArray(using: [NSSortDescriptor(key: kVerseId, ascending: true)]) as NSArray
        
        let contents:NSMutableDictionary = [:]
        let keys:NSMutableArray = []
        
        var chapter: Chapter
        var verse: Verse
        var values: NSMutableArray
        var key: String
        
        //Construct the key list with empty content
        for item in sortedBookmarksByChapter {
            chapter = dollar.chapters[(item as AnyObject).object(forKey: kChapterhId) as! Int]
            key = dollar.getKeyId(chapter)
            if (contents.object(forKey: key) == nil) {
                keys.add(key)
                contents.setObject(NSMutableArray(), forKey: key as NSCopying)
            }
        }
        
        //fill in the content of the keys
        for item in sortedBookmarksByVerse {
            chapter = dollar.chapters[(item as AnyObject).object(forKey: kChapterhId) as! Int]
            key = dollar.getKeyId(chapter)
            if (contents.object(forKey: key) != nil) {
                values = (contents.object(forKey: key) as? NSMutableArray)!
                if (item as AnyObject).object(forKey: kChapterhId) as? Int == chapter.id {
                    var verseId: Int = ((item as AnyObject).object(forKey: kVerseId) as? Int)!
                    if chapter.id == kFatihaIndex || chapter.id == kTaubahIndex {
                        verseId = verseId - 1
                    }
                    verse = chapter.verses[verseId]
                    values.add(verse)
                }
                contents.setObject(values, forKey: key as NSCopying)
            }
        }
        return (keys: keys, contents: contents)
    }
}
