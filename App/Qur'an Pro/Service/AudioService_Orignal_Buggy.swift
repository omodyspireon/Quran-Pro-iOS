//
//  AudioService.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import Foundation
import AVFoundation
import MediaPlayer

struct Repeats {
    var verses = ["Play verse once".local, "Play verse twice".local, "Play 3 times".local, "Play 4 times".local, "Play 5 times".local, "Play 10 times".local, "Play 15 times".local, "Play 20 times", "Play 25 times".local, "Keep playing verse".local]
    var chapters = ["Play chapter by chapter".local, "Play chapter once".local, "Play chapter twice".local, "Play chapter 3 times".local, "Play chapter 4 times".local, "Play chapter 5 times".local, "Play chapter 10 times".local, "Play chapter 15 times".local, "Play chapter 20 times".local, "Play chapter 25 times".local, "Keep playing chapter".local]
    var verseCount: Int = 1
    var chapterCount: Int = 1
    var speedCount: Int = 1
}

protocol AudioDelegate {
    func playNextChapter()
    func scrollToVerse(_ verseId: Int, searchText: String?)
}

private let _AudioServiceSharedInstance = AudioService()

class AudioService: NSObject, AVAudioPlayerDelegate {

    class func sharedInstance() -> AudioService {
        return _AudioServiceSharedInstance
    }

    // hold a reference to a delegate
    var delegate: AudioDelegate?
    var currentVerseIndex: Int!
    var isPaused: Bool!
    var fullRepeatEndIndex: Int!
    var isFullRepeat: Bool!
    var savedCurrentVerseIndex: Int!
    var fullRepeatCount: Int!
    var currentRepeatCount: Int!
    var startIndex: Int!
    var endIndex: Int!
    var didFindVerseStart: Bool!
    var didFindVerseEnd: Bool!
    var abRepeatStartIndex: Int!
    var abRepeatEndIndex: Int!
    var setupABRepeat: Bool!

    // hold the repeat verses and chapters string
    var repeats: Repeats!

    // hold the player instance
    fileprivate var player: AVAudioPlayer?

    override init() {
        super.init()
        self.isPaused = false
        self.repeats = Repeats()
        self.currentVerseIndex = 0
        self.fullRepeatEndIndex = 1
        self.isFullRepeat = false
        self.savedCurrentVerseIndex = 0
        self.fullRepeatCount = 0
        self.currentRepeatCount = 0
        self.abRepeatStartIndex = 1
        self.abRepeatEndIndex = 0
        self.didFindVerseStart = false
        self.didFindVerseEnd = false
        self.setupABRepeat = false
    }

    func initDelegation(_ delegate: AudioDelegate?) {
        if delegate != nil {
            self.delegate = delegate
        }
    }

    func setPlayVerse(_ verseToPlay: Verse? = nil) {
        if verseToPlay != nil {
            self.currentVerseIndex = dollar.currentChapter.verses.index(of: verseToPlay!)
            self.fullRepeatEndIndex = self.currentVerseIndex
            setupABRepeatPlayer()
            resetABRepeat()
        }
    }

    // play the passed verse index
    // @param verseToPlay verse to play or the first one if nothing is passed
    func play(_ verseToPlay: Verse? = nil) {
        // cute little demo
        let mpic = MPNowPlayingInfoCenter.default()
        var dic = [String: AnyObject]()
        dic[MPMediaItemPropertyTitle] = kApplicationDisplayName as AnyObject
        dic[MPMediaItemPropertyArtist] = "\(dollar.currentChapter.name) - \(dollar.currentReciter.name)" as AnyObject
        dic[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: UIImage(named: "launch-screen")!)
        mpic.nowPlayingInfo = dic

        var verse: Verse!
        let audioChapter: AudioChapter = dollar.currentReciter.audioChapters[dollar.currentChapter.id]
        if verseToPlay == nil {
            verse = dollar.currentChapter.verses[0]
            self.currentVerseIndex = 0
            setupABRepeatPlayer()
            resetABRepeat()
            if self.currentVerseIndex > 0 {
                verse = dollar.currentChapter.verses[currentVerseIndex]
            }
        } else {
            verse = verseToPlay
            self.currentVerseIndex = dollar.currentChapter.verses.index(of: verse)
        }

        delegate?.scrollToVerse(self.currentVerseIndex, searchText: "")

        let path: String  = audioChapter.verseAudioPath(verse)
        let url: URL = URL(fileURLWithPath: path, isDirectory: false)
        var error: NSError?

        // remove the old player if exist
        self.isPaused = false

        // create a new instance of the player the new data
        do {
            self.player = try AVAudioPlayer(contentsOf: url)
        } catch let error1 as NSError {
            error = error1
        }
        self.player?.enableRate = true
        setDefaultRate()
        self.player?.prepareToPlay()
        self.player?.delegate = self
        // set the number of loops
        if isFullRepeat == true || currentVerseIndex == 0 {
            self.player?.numberOfLoops = 0
        } else {
            self.player?.numberOfLoops = self.repeats.verseCount
        }

        switch self.repeats.chapterCount {
        case 0:
            self.fullRepeatCount = 0
            break
        case 1:
            self.fullRepeatCount = 1
            break
        case 3:
            self.fullRepeatCount = 3
            break
        case 4:
            self.fullRepeatCount = 4
            break
        case 5:
            self.fullRepeatCount = 5
            break
        case 6:
            self.fullRepeatCount = 10
            break
        case 7:
            self.fullRepeatCount = 15
            break
        case 8:
            self.fullRepeatCount = 20
            break
        case 9:
            self.fullRepeatCount = 25
            break
        default:
            self.fullRepeatCount = 1
        }

        // if no error were found, play the verse
        if error == nil {
            self.player?.play()
            self.isPaused = false
        }
    }

    // rest the player
    fileprivate func resetPlayer() {
        self.player?.stop()
        self.player?.delegate = nil
        // self.player = nil
        self.isPaused = false
    }

    func resetABRepeat() {
        self.currentVerseIndex = abRepeatStartIndex
    }

    // MARK: AVAudioPlayerDelegate

    func setupABRepeatPlayer() {
        // if(!self.setupABRepeat) {
            self.setupABRepeat = true
            self.abRepeatEndIndex = dollar.currentChapter.verses.count - 1
            for verse in dollar.currentChapter.verses {
                if ABRepeatService.sharedInstance().has(verse) {
                    if !didFindVerseStart {
                        didFindVerseStart = true
                        currentVerseIndex = verse.id
                        abRepeatStartIndex = currentVerseIndex
                        fullRepeatEndIndex = currentVerseIndex + 1
                        continue
                    }
                    if !didFindVerseEnd && didFindVerseStart {
                        didFindVerseEnd = true
                        abRepeatEndIndex = verse.id
                        break
                    }
                }
            }
        // }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // start playing the first verses
        if currentVerseIndex < dollar.currentChapter.verses.count - 1 && currentVerseIndex < abRepeatEndIndex {
            if (currentVerseIndex == 0 || currentVerseIndex == abRepeatStartIndex) && isFullRepeat == false { // first first ayah then continue to next one
                currentVerseIndex = currentVerseIndex + 1
                play(dollar.currentChapter.verses[currentVerseIndex])
            } else {
                if currentVerseIndex == fullRepeatEndIndex { // now start full repeat
                    isFullRepeat = true
                    savedCurrentVerseIndex = currentVerseIndex
                    currentVerseIndex = abRepeatStartIndex
                    fullRepeatEndIndex = fullRepeatEndIndex + 1
                    isFullRepeat = true
                    // resetPlayer()
                    // resetABRepeat()
                    play(dollar.currentChapter.verses[abRepeatStartIndex])
                } else {
                    currentVerseIndex = currentVerseIndex + 1
                    if currentVerseIndex == fullRepeatEndIndex {
                        if currentRepeatCount >= fullRepeatCount {
                            isFullRepeat = false
                            currentRepeatCount = 0
                        } else {
                            currentRepeatCount = currentRepeatCount + 1
                            currentVerseIndex = abRepeatStartIndex
                            // resetPlayer()
                            // resetABRepeat()
                            play(dollar.currentChapter.verses[abRepeatStartIndex])
                        }
                    }
                    play(dollar.currentChapter.verses[currentVerseIndex])
                }

            }
        }
        // all verses has been played, check what to do next
        else {
            currentVerseIndex = 0
            if didFindVerseStart == true {
                currentVerseIndex = abRepeatStartIndex
            }

            // resetPlayer()
            // setupABRepeatPlayer()

            // case: 'Play chapter by chapter'
            // check if we can play the next chapter
            if self.repeats.chapterCount == 0 {
                // ask the delegate if we can play the next chapter
                delegate?.playNextChapter()
            }
            // case: 'Play chapter once'
            else if self.repeats.chapterCount == 1 {
                // do nothing, just stop here...
            }
            // case: 'Keep playing chapter'
            else if self.repeats.chapterCount >= 2 {
                play(dollar.currentChapter.verses[abRepeatStartIndex])
            }
        }
    }

    // MARK: Utils

    // resume playing the current audio
    func resumePlaying() {
        if self.isPaused == true {
            self.player?.play()
            self.isPaused = false
        } else {
            play()
        }
    }

    // pause playing the current audio
    func pausePlaying() {
        self.isPaused = true
        self.player?.pause()
    }

    func stopPlaying() {
        self.isPaused = true
        self.player?.stop()
    }

    // play the next audio if any
    func playNext() {
        let total = dollar.currentChapter.verses.count
        if currentVerseIndex < total - 1 {
            currentVerseIndex = currentVerseIndex + 1
            fullRepeatEndIndex = currentVerseIndex
            play(dollar.currentChapter.verses[currentVerseIndex])
            self.isPaused = false
        }
    }

    // play the previous audio if any
    func playPrevious() {
        if currentVerseIndex > 0 {
            currentVerseIndex = currentVerseIndex - 1
            fullRepeatEndIndex = currentVerseIndex
            play(dollar.currentChapter.verses[currentVerseIndex])
            self.isPaused = false
        }
    }

    // update the current played audio with the corrent numberOfLoops
    func repeatPlay() {
        // Case: "Keep playing verse"
        if repeats.verseCount == repeats.verses.count - 2 {
            repeats.verseCount = -1
        }
        // other cases
        else {
            repeats.verseCount = repeats.verseCount + 1
        }

        // set the number of loops
        self.player?.numberOfLoops = repeats.verseCount

        // save the repeat value of the disk
        dollar.setPersistentObjectForKey(repeats.verseCount as AnyObject, key: kCurrentRepeatVerseKey)
        NotificationCenter.default.post(name: Notification.Name(rawValue: kRepatCountChangedNotification), object: nil, userInfo: nil)
    }

    // update the current played audio with the corrent numberOfLoops
    func speedPlay() {
        // Case: "Keep playing verse"
        if repeats.speedCount >= 4 {
            repeats.speedCount = 0
            self.player?.rate = 0.5
        } // other cases
        else {
            repeats.speedCount = repeats.speedCount + 1
            if repeats.speedCount == 1 {
                self.player?.rate = 0.75
            } else if repeats.speedCount == 2 {
                self.player?.rate = 1.0
            } else if repeats.speedCount == 3 {
                self.player?.rate = 1.5
            } else if repeats.speedCount == 4 {
                self.player?.rate = 2.0
            }
        }

        // save the repeat value of the disk
        dollar.setPersistentObjectForKey(repeats.speedCount as AnyObject, key: kCurrentSpeedVerseKey)
        NotificationCenter.default.post(name: Notification.Name(rawValue: kSpeedCountChangeNotification), object: nil, userInfo: nil)
    }

    // update the current played audio with the corrent numberOfLoops
    func setDefaultRate() {
        if repeats.speedCount == 0 {
            self.player?.rate = 0.5
        } else if repeats.speedCount == 1 {
            self.player?.rate = 0.75
        } else if repeats.speedCount == 2 {
            self.player?.rate = 1.0
        } else if repeats.speedCount == 3 {
            self.player?.rate = 1.5
        } else if repeats.speedCount == 4 {
            self.player?.rate = 2.0
        }
    }

    // stops and resets the player
    func stopAndReset() {
        resetPlayer()
    }

    // check whether the audio is played or not
    func isPlaying() -> Bool {
        return self.player != nil && self.player!.isPlaying
    }

    // get the icon name of the repeat control
    func repeatIconName() -> String {
        if repeats.verseCount == -1 {
            return "repeat-∞"
        } else {
            return "repeat-\(repeats.verseCount + 1)"
        }
    }

    func speedIconName() -> String {
        if repeats.speedCount == 0 {
            return "half"
        } else if repeats.speedCount == 1 {
            return "threeforth"
        } else if repeats.speedCount == 3 {
            return "oneandhalf"
        } else if repeats.speedCount == 4 {
            return "double"
        } else {
            return "normal"
        }
    }

    deinit {
        self.player?.delegate = nil
        self.player = nil
    }
}
