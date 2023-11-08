//
//  Setting.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import UIKit

// Define the menu option
enum SettingType: Int {
    case settingTypeSearch = 0,
    settingTypeBookmark,
    settingTypeAudioDownload,
    settingTypeRecitator,
    settingTypeTranslation,
    settingTypeVersePlayOption,
    settingTypeChapterPlayOption,
    settingTypeChapterViewOption,
    settingTypeSearchOption,
    settingTypeTellAFriend,
    settingTypeAppReview,
    settingTypeIslamicApps,
    settingTypeContactUs
}

class Setting: CustomStringConvertible {
    var name: String!
    var icon: UIImage!
    var type: SettingType!

    init(name: String, imageName: String, type: SettingType) {
        self.name = name
        self.icon = UIImage(named: imageName)
        self.type = type
    }

    var description: String {
        return "name= \(name ?? "name") type=\(type ?? .settingTypeAppReview)"
    }
}
