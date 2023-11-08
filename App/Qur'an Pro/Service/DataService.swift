//
//  DataService.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import Foundation

enum PartQuarterType: Int {
    case one = 0, // 1
    oneFourth, // 1/4
    half, // 1/2
    threeFourth // 3/4
}

enum RevelationLocationTpe: String {
    case Mecca = "Mecca",
    Medina = "Medina"
}

enum VerseViewType: Int {
    case noTranslation = 0,
    noTransliteration
}

enum ArabicFontType: Int {
    case useMEQuranicFont = 0,
    usePDMSQuranicFont,
    useNormalArabicFont
}

enum FontSizeType: Int {
    case medium = 0,
    large,
    extraLarge
}

enum GroupViewType: Int {
    // 0- Suras
    // 1- Ajzaa'
    case groupChaptersView = 0, groupPartsView
}

enum SearchOption: Int {
    case searchOptionTraslation = 0, searchOptionArabic, searchOptionTrasliteration
}

private let _DataServiceSharedInstance = DataService()

class DataService {

    class func sharedInstance() -> DataService {
        return _DataServiceSharedInstance
    }

    // list the all chapters
    var chapters: Array<Chapter>!
    // list of all verses
    var verses: Array<Verse>!
    // list of recites
    var reciters: Array<Reciter>!
    // list of the supported translations
    var translations: Array<Translation>!
    // current language
    var currentLanguageKey: String!
    // current reciter
    var currentReciter: Reciter!
    // current reciter
    var currentReciterIndex: Int!
    // current chapter
    var currentChapter: Chapter!
    // current chapter
    var currentChapterIndex: Int!
    // show allow download on 3G
    var allowDownloadOn3G: Bool
    // should show the translations
    var showTranslation: Bool
    // should show the transliteration
    var showTransliteration: Bool
    // font level
    var fontLevel: FontSizeType
    // should show the transliteration
    var searchOption: SearchOption
    // save the group view type
    var currentGroupViewType: GroupViewType!

    // current arabic font
    var arabicFont: ArabicFontType

    // parts (juz')
    var parts: [Part]

    init() {
        // inits the variables
        self.currentLanguageKey = kAppDefaultLanguage
        self.chapters = []
        self.verses = []
        self.reciters = []
        self.translations = []
        self.allowDownloadOn3G = false
        self.showTranslation = true
        self.showTransliteration = true
        self.fontLevel = FontSizeType.medium
        self.searchOption = .searchOptionTraslation
        self.arabicFont = .useMEQuranicFont
        self.parts = []

        // sets the part(juz)
        self.initParts()

        // sets the current chapter
        self.initializeFromSetting()

        // load the languages
        self.loadTranslations()

        // init lang
        self.initLanguage()

        // init the chapters
        self.retrieveChapters()

        // init the content
        self.loadContent()

        // load the reciter data
        self.loadReciters()

        // init the current reciter and chapter
        self.currentChapter = chapters[self.currentChapterIndex]
        self.currentReciter = reciters[self.currentReciterIndex]
    }

    // check the availability of the passed lang
    func isLanguageAvailable(_ langKey: String) -> Bool {
        for translation in translations {
            if translation.id == langKey {
                return true
            }
        }
        return false
    }

    // init the current language
    func initLanguage() {
        if isPro {
            if currentLanguageKey != nil && isLanguageAvailable(currentLanguageKey) {
                // just use it
            } else if isLanguageAvailable(UserDefaults.currentLanguageKey()) {
                currentLanguageKey = UserDefaults.currentLanguageKey()
            } else {
                currentLanguageKey = kAppDefaultLanguage
            }
        } else {
            currentLanguageKey = kAppDefaultLanguage
        }
    }

    // init the parts
    func initParts() {

        let items = NSMutableDictionary()
        var output = [NSMutableArray]()
        var juz = 1
        var count = 0
        for i in 0..<kPartQuarts.count {
            let array: NSMutableArray!
            if let a = items.object(forKey: juz) as? NSMutableArray {
                array = a
            } else {
                array = NSMutableArray()
                items.setObject(array, forKey: juz as NSCopying)
                output.append(array)
            }
            array.add(kPartQuarts[i])
            if i <= 7 {
                if count == 7 {
                    count = 0
                    juz += 1
                }
            } else {
                if count == 8 {
                    count = 0
                    juz += 1
                }
            }
            count += 1
        }

        var hizb = 0
        for i in 0..<output.count {
            let quarters = output[i]
            let partid = i+1
            let part = Part(id: partid)
            for j in 0..<quarters.count {
                if let quarter = quarters[j] as? [Int] {
                    if j == 0 || j == 4 {
                        hizb += 1
                    }
                    let type = j > 3 ? PartQuarterType(rawValue: j-4) : PartQuarterType(rawValue: j)
                    let partQuarter = PartQuarter(parentId: partid, chapterId: quarter[0], verseId: quarter[1], type: type!, hizbId: hizb)
                    part.partQuarters.append(partQuarter)
                }

            }
            self.parts.append(part)
        }
    }

    // loads the chapters from the local data
    func retrieveChapters() {
        if let list = Bundle.readArrayPlist("chapters") {
            chapters = []
            var item: [String: String]!
            var chapter: Chapter!
            var verse: Verse
            for i in 0...(list.count-1) {
                item = list[i] as! [String: String]
                chapter = Chapter(id: i, name: item["name"]!, revelationLocation: item["rev"]!)

                // Adds a basmalah into all chapters, except Al-Fatiha(0) and Al-Taubah(8)
                if i != kTaubahIndex && i != kFatihaIndex {
                    verse = Verse(id: -1, chapterId: i, arabic: kBasmallah, nonVocalArabic: "", translation: "", transcription: "", hizbId: -1)
                    chapter.verses.append(verse)
                }
                chapters.append(chapter)
            }
        }
    }

    // update the application content
    // a new translation has been selected
    func updateContent() {

        // load the chpaters again
        retrieveChapters()

        // load the new content
        loadContent()

        // set the current item
        dollar.currentChapter = chapters[dollar.currentChapter.id]

        // notify the ui to update the content
        NotificationCenter.default.post(name: Notification.Name(rawValue: kTranslationChangedNotification), object: nil, userInfo: nil)
    }

    // loads the application content from the local data
    func loadContent() {
        var hizbId: Int!
        var chapterId: Int!
        var verseId: Int!
        var chapter: Chapter!
        var verse: Verse!
        // empty the old content
        verses = []

        if let arabic = Bundle.readArrayPlist(kArabicFile) {
            if let arabic2 = Bundle.readArrayPlist(kArabic2File) {
                if let transcription = Bundle.readArrayPlist(kTranscriptionFile) {
                    do {
                        try SSZipArchive.unzipFile(atPath: Bundle.main.path(forResource: currentLanguageKey, ofType: "zip")!, toDestination: Bundle.documents(), overwrite: true, password: "Bu##erV1@@i")
                        if let translation = Bundle.readArrayPlistFromDocumentFolder(currentLanguageKey) {
                            let delayTime = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                                DispatchQueue.main.async {
                                    var e: NSError?
                                    let docs = Bundle.documents()
                                    let pathToRemove: String = docs! + "/\(self.currentLanguageKey).plist"
                                    // let pathToRemove: String = "\(Bundle.documents())/\(self.currentLanguageKey).plist"
                                    do {
                                        try FileManager.default.removeItem(atPath: pathToRemove)
                                    } catch let error as NSError {
                                        e = error
                                    } catch {
                                        fatalError()
                                    }
                                    if e != nil {
                                        // Flurry.logError(FlurryEvent.removeTranslation, message: "Cannot remove file: \(pathToRemove)", error: e)
                                    }
                                }
                            }
                            for i in 0...(translation.count-1) {
                                if let item = translation[i] as? NSDictionary {
                                    hizbId = -1
                                    if item.object(forKey: "h") != nil { hizbId = (item.object(forKey: "h") as AnyObject).intValue }
                                    if item.object(forKey: "s") != nil { chapterId = (item.object(forKey: "s") as AnyObject).intValue }
                                    if item.object(forKey: "a") != nil { verseId = (item.object(forKey: "a") as AnyObject).intValue }

                                    // http://en.wikipedia.org/wiki/Arabic_(Unicode_block)
                                    let ar = hizbId != -1 ? "۞ \(arabic[i] as! String)" : arabic[i] as! String
                                    let nonvocalar = hizbId != -1 ? "۞ \(arabic2[i] as! String)" : arabic[i] as! String
                                    verse = Verse(id: verseId, chapterId: chapterId - 1, arabic: ar, nonVocalArabic: nonvocalar, translation: item.object(forKey: "t") as! String, transcription: transcription[i] as! String, hizbId: hizbId)
                                    verses.append(verse)

                                    if chapterId > 0 {
                                        chapter = chapters[chapterId - 1]
                                        chapter.verses.append(verse)
                                    }
                                }
                            }
                        }
                    } catch _ {
                    }
                }
            }
        }
    }

    // loads the reciters data
    func loadReciters() {
        var reciter: Reciter!
        var audioChapter: AudioChapter!
        if let lReciters = Bundle.readArrayPlist(kRecitersFile) {
            for i in 0...(lReciters.count - 1) {
                if let lReciter: NSDictionary = lReciters[i] as? NSDictionary {
                    reciter = Reciter(id: i, name: lReciter.object(forKey: "n") as! String)
                    if reciter.mirrors[MirrorIndex.abm.rawValue] == nil || reciter.mirrors[MirrorIndex.pma.rawValue] == nil {
                        reciter.mirrors[MirrorIndex.abm.rawValue] = lReciter.object(forKey: "m1") as? String
                        reciter.mirrors[MirrorIndex.pma.rawValue] = lReciter.object(forKey: "m2") as? String
                    }

                    if let lChatpers: NSArray = lReciter.object(forKey: "i") as? NSArray {
                        for j in 0...(lChatpers.count - 1) {
                            if let lChapter: NSDictionary = lChatpers[j] as? NSDictionary {
                                let sizeAsNSString: NSString = lChapter.object(forKey: "s") as! NSString
                                let fileName: String = lChapter.object(forKey: "fn") as! String
                                audioChapter = AudioChapter(id: j, parent: reciter, fileName: fileName, size: sizeAsNSString.longLongValue)
                                reciter.audioChapters.append(audioChapter)
                            }
                        }
                    }
                    reciters.append(reciter)
                }
            }
        }
    }

    // loads the translations data
    func loadTranslations() {
        var translation: Translation!
        if let kTranslations = Bundle.readArrayPlist(kTranslationsFile) {
            for i in 0...(kTranslations.count - 1) {
                if let kTranslation: NSDictionary = kTranslations[i] as? NSDictionary {
                    translation = Translation(id: kTranslation.object(forKey: "id") as! String, name: kTranslation.object(forKey: "name") as! String, iconName: kTranslation.object(forKey: "icon") as! String)
                    translations.append(translation)
                }
            }
        }
    }

    // init the properties from the settings
    func initializeFromSetting() {
        if let userSettings: NSMutableDictionary = Bundle.readDictionaryPlistFromDocumentFolder(kUserSettingsFile) {
            // Current chapter
            if let value: Int =  userSettings.object(forKey: kCurrentChapterKey) as? Int {
                self.currentChapterIndex = value
            } else {
                self.currentChapterIndex = 0
            }

            // Translation
            if let value: Int =  userSettings.object(forKey: kShowTranslationKey) as? Int {
                self.showTranslation = value == 1
            }

            // Translatiration
            if let value: Int =  userSettings.object(forKey: kShowTransliterationKey) as? Int {
                self.showTransliteration = value == 1
            }

            // Font level
            if let value: Int =  userSettings.object(forKey: kCurrentFontLevelKey) as? Int {
                self.fontLevel = FontSizeType(rawValue: value)!
            }

            // Search option
            if let value: Int =  userSettings.object(forKey: kCurrentSearchOptionKey) as? Int {
                self.searchOption = SearchOption(rawValue: value)!
            }

            // Repeat chapter
            if let value: Int =  userSettings.object(forKey: kCurrentRepeatChapterhKey) as? Int {
                AudioService.sharedInstance().repeats.chapterCount = value
            }

            // Repeat verse
            if let value: Int =  userSettings.object(forKey: kCurrentRepeatVerseKey) as? Int {
                AudioService.sharedInstance().repeats.verseCount = value
            }

            if let value: Int =  userSettings.object(forKey: kCurrentSpeedVerseKey) as? Int {
                AudioService.sharedInstance().repeats.speedCount = value
            }

            // Load the current reciter
            if let value: Int = userSettings.object(forKey: kCurrentReciterKey) as? Int {
                self.currentReciterIndex = value
            } else {
                self.currentReciterIndex = 0
            }

            if let value: String = userSettings.object(forKey: kCurrentTranslationKey) as? String {
                self.currentLanguageKey = value
            }

            if let value: Int = userSettings.object(forKey: kCurrentArabicFontKey) as? Int {
                self.arabicFont = ArabicFontType(rawValue: value)!
            } else {
                if let value: Int = userSettings.object(forKey: kUseQuranicFontKey) as? Int {
                    // use the normal arabic font
                    if value == 0 {
                        self.arabicFont = ArabicFontType.useNormalArabicFont
                    } else {
                        self.arabicFont = ArabicFontType.useMEQuranicFont
                    }
                }
            }

            // load the group view type
            if let value: Int = userSettings.object(forKey: kGrouViewTypeKey) as? Int {
                self.currentGroupViewType = GroupViewType(rawValue: value)!
            } else {
                self.currentGroupViewType = .groupChaptersView
            }
        } else {
            // create a temp file applicationVersion
            let userSettings: NSMutableDictionary = [kApplicationVersionKey: kApplicationVersion,
                kCurrentTranslationKey: currentLanguageKey,
                kCurrentReciterKey: 1,
                kCurrentRepeatVerseKey: 0, // 4,
                kCurrentRepeatChapterhKey: 0, // 4,
                kShowTranslationKey: 1,
                kShowTransliterationKey: 1,
                kCurrentFontLevelKey: 0,
                kCurrentSearchOptionKey: 0,
                kCurrentArabicFontKey: 0,
                kGrouViewTypeKey: 0,
                kCurrentSpeedVerseKey: 2
            ]

            // write down the files into the document folder
            Bundle.writeDictionaryPlistToDocumentFolder(filename: kUserSettingsFile, dictionary: userSettings)

            // set the default values
            self.currentChapterIndex = 0
            self.currentReciterIndex = 1
            self.showTranslation = true
            self.showTransliteration = true
            self.fontLevel = FontSizeType.medium
            self.searchOption = SearchOption.searchOptionTraslation
            self.arabicFont = .useMEQuranicFont
            AudioService.sharedInstance().repeats.chapterCount = 0 // 4
            AudioService.sharedInstance().repeats.verseCount = 0 // 4
            AudioService.sharedInstance().repeats.speedCount = 2
            self.currentGroupViewType = .groupChaptersView
        }
    }

    // sets a saves the current chapter to the persistent data
    // @param chapter   The chapter to set as current and to save in the persistent data
    func setAndSaveCurrentChapter(_ chapter: Chapter) {
        self.currentChapter = chapter

        let userSettings: NSMutableDictionary? = Bundle.readDictionaryPlistFromDocumentFolder(kUserSettingsFile)
        let index = self.chapters.index(of: chapter)
        userSettings?.setObject((index!>=0 ? index : 0)!, forKey: kCurrentChapterKey as NSCopying)
        Bundle.writeDictionaryPlistToDocumentFolder(filename: kUserSettingsFile, dictionary: userSettings!)
    }

    /// Sets the object/key in the persistent data
    func setPersistentObjectForKey(_ object: AnyObject, key: String) {
        let userSettings: NSMutableDictionary? = Bundle.readDictionaryPlistFromDocumentFolder(kUserSettingsFile)
        userSettings?.setObject(object, forKey: key as NSCopying)
        Bundle.writeDictionaryPlistToDocumentFolder(filename: kUserSettingsFile, dictionary: userSettings!)
    }

    // get the keyId based on the chapter id and name
    func getKeyId(_ chapter: Chapter) -> String {
        return "\(chapter.id + 1). \(chapter.name)"
    }
}

// Simplfy the data manager call to the $ sign
var dollar: DataService = DataService.sharedInstance()
