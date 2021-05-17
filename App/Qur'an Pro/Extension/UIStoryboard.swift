//
//  UIStoryboard.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import Foundation
import UIKit

extension UIStoryboard {
    @objc class func mainStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: Bundle.main)
    }
    
    @objc class func moreViewController() -> MoreViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "MoreViewController") as? MoreViewController
    }
    
    @objc class func chaptersViewController() -> ChaptersViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "ChaptersViewController") as? ChaptersViewController
    }
    
    @objc class func centerViewController() -> CenterViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "CenterViewController") as? CenterViewController
    }
    
    @objc class func downloadViewController() -> DownloadViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "DownloadViewController") as? DownloadViewController
    }
    
    @objc class func bookMarkViewController() -> BookmarkViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "BookmarkViewController") as? BookmarkViewController
    }
    
    @objc class func searchViewController() -> SearchViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController
    }
    
    @objc class func searchOptionsViewController() -> SearchOptionViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "SearchOptionViewController") as? SearchOptionViewController
    }

    @objc class func recitersViewController() -> RecitersViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "RecitersViewController") as? RecitersViewController
    }
    
    @objc class func versePlayOptionViewController() -> VersePlayOptionViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "VersePlayOptionViewController") as? VersePlayOptionViewController
    }

    @objc class func chapterPlayOptionViewController() -> ChapterPlayOptionViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "ChapterPlayOptionViewController") as? ChapterPlayOptionViewController
    }

    @objc class func chapterViewOptionViewController() -> ChapterViewOptionViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "ChapterViewOptionViewController") as? ChapterViewOptionViewController
    }
    @objc class func translationViewController() -> TranslationViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "TranslationViewController") as? TranslationViewController
    }
    
    @objc class func winPageContentViewController() -> WINPageContentViewController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "WINPageContentViewController") as? WINPageContentViewController
    }
    
    
}
