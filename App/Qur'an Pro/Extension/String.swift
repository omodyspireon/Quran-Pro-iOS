//
//  String.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import Foundation

// simplfy the localization call
extension String {
    var local: String {
        get {
            return NSLocalizedString(self, comment: "")
        }
    }

    func localizeWithFormat(_ args: CVarArg...) -> String {
        return String(format: self, locale: nil, arguments: args)
    }
    func localizeWithFormat(_ local: Locale?, args: CVarArg...) -> String {
        return String(format: self, locale: local, arguments: args)
    }

    var lastPathComponent: String {
        get {
            return (self as NSString).lastPathComponent
        }
    }
    var pathExtension: String {
        get {
            return (self as NSString).pathExtension
        }
    }

    var stringByDeletingLastPathComponent: String {
        get {
            return (self as NSString).deletingLastPathComponent
        }
    }

    var stringByDeletingPathExtension: String {
        get {
            return (self as NSString).deletingPathExtension
        }
    }

    var pathComponents: [String] {
        get {
            return (self as NSString).pathComponents
        }
    }

    func stringByAppendingPathComponent(_ path: String) -> String {
        let nsSt = self as NSString
        return nsSt.appendingPathComponent(path)
    }

    func stringByAppendingPathExtension(_ ext: String) -> String? {
        let nsSt = self as NSString
        return nsSt.appendingPathExtension(ext)
    }
}
