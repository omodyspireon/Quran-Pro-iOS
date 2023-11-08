//
//  Verse.swift // Ayah
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import Foundation

class Verse: NSObject {

    // verse id
    @objc var id: Int
    // chapter id
    @objc var chapterId: Int
    // arabic content
    @objc var arabic: String
    // arabic content without arabic vocals (tashkeel) for searching feature
    @objc var nonVocalArabic: String
    // translation content
    @objc var translation: String
    // transcription content
    @objc var transcription: String
    // hizb id
    @objc var hizbId: Int

    // Inits the class
    @objc init(id: Int, chapterId: Int, arabic: String, nonVocalArabic: String, translation: String, transcription: String, hizbId: Int) {
        self.id = id
        self.chapterId = chapterId
        self.arabic = arabic
        self.nonVocalArabic = nonVocalArabic
        self.translation = translation
        self.transcription = transcription
        self.hizbId = hizbId
    }

    override var description: String {
        return "id: \(id), chapterId: \(chapterId), hizbId: \(hizbId)"
    }

    // mumber prefix
    @objc var numberPrefix: String {
        let hizbPrefix = self.hizbId != -1 ? "[Hizb \(self.hizbId)]" : ""
        return "\(hizbPrefix) \(self.chapterId + 1):\(self.id)"
    }

    // search options values
    @objc var nonVocalArabicSearch: String {
        return "\(self.numberPrefix) \(self.nonVocalArabic)"
    }
    @objc var translationSearch: String {
        return "\(self.numberPrefix) \(self.translation)"
    }
    @objc var transcriptionSearch: String {
        return "\(self.numberPrefix) \(self.transcription)"
    }

    // return the audio file name
    @objc var fileName: String {
        var index: Int = id
        if chapterId == kFatihaIndex  || chapterId == kTaubahIndex {
            index =  id - 1
        } else if id == -1 {
            index =  0
        }
        if index < 10 {
            return "00\(index).mp3"
        } else if index < 100 && index >= 10 {
            return "0\(index).mp3"
        } else {
            return "\(index).mp3"
        }
    }

    @objc var fileNameForSpecialReciterFolder: String {
        let index: Int = id - 1

        if index < 10 {
            return "00\(index).mp3"
        } else if index < 100 && index >= 10 {
            return "0\(index).mp3"
        } else {
            return "\(index).mp3"
        }
    }

    override func isEqual(_ object: Any?) -> Bool {
        if let rhs = object as? Verse {
            return id == rhs.id && chapterId == rhs.chapterId
        }
        return false
    }

}

func == (lhs: Verse, rhs: Verse) -> Bool {
    return lhs.id == rhs.id && lhs.chapterId == rhs.chapterId
}
