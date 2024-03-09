//
//  Reciter.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import Foundation

class Reciter: Equatable, CustomStringConvertible {

    var id: Int
    var name: String
    var audioChapters: [AudioChapter]
    var mirrors: [String?]
    var mirrorIndex: MirrorIndex

    init (id: Int, name: String) {
        self.id = id
        self.name = name
        audioChapters = []
        mirrors = [String?](repeating: nil, count: 4)
        mirrorIndex = MirrorIndex.abm
    }

    var description: String {
        return "id= \(id), name= \(name), mirrors= \(mirrors)"
    }
}

func == (lhs: Reciter, rhs: Reciter) -> Bool {
    return lhs.id == rhs.id && lhs.name == rhs.name
}
