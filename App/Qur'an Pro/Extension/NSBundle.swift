//
//  NSBundle.swift
//  Qur'an Pro
//
//  Created by Adil Ben Moussa on 10/27/15.
//  Copyright © 2015 https://github.com/adilbenmoussa All rights reserved.
//  GNU GENERAL PUBLIC LICENSE https://raw.githubusercontent.com/adilbenmoussa/Quran-Pro-iOS/master/LICENSE
//

import Foundation

extension Bundle {
    
    @objc class func documents() -> String! {
        let dirs: [AnyObject] = NSSearchPathForDirectoriesInDomains(.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true) as [AnyObject]
        return dirs[0] as? String
    }
    
    @objc class func readPlist(_ filename: String, fromDocumentsFolder: Bool=false) -> AnyObject? {
        let plist:AnyObject?
        if let path = Bundle.main.path(forResource: filename, ofType: "plist") {
            let data: Data?
            do {
                data = try Data(contentsOf: URL(fileURLWithPath: path), options: NSData.ReadingOptions())
            } catch  {
                data = nil
            }
            do {
                plist = try PropertyListSerialization.propertyList(from: data!, options: PropertyListSerialization.MutabilityOptions(), format: nil) as AnyObject
                return plist
            } catch  {
                plist = nil
            }
        }
        return nil
    }
    
    @objc class func readArrayPlist(_ filename: String) -> NSArray? {
        if let array: AnyObject = readPlist(filename) {
            if let array = array as? NSArray? {
                return array
            }
            else{
                print("Loaded plist file '\(filename)' is not NSArray")
            }
        }
        return nil
    }
    
    @objc class func readDictionayPlist(_ filename: String) -> NSDictionary? {
        if let dictinary: AnyObject = readPlist(filename) {
            if let dictinary = dictinary as? NSDictionary? {
                return dictinary
            }
            else{
                print("Loaded plist file '\(filename)' is not NSDictionary")
            }
        }
        return nil
    }
    
    @objc class func writeArrayPlistToDocumentFolder(filename: String, array: NSArray) {
        let path:String = documents().stringByAppendingPathComponent("\(filename).plist")
        array.write(toFile: path, atomically:true)
    }
    
    @objc class func readArrayPlistFromDocumentFolder(_ filename: String) -> NSArray? {
        let path:String = documents().stringByAppendingPathComponent("\(filename).plist")
        if let array: NSArray = NSArray(contentsOfFile: path) {
            return array
        }
        return nil;
    }
    
    @objc class func writeDictionaryPlistToDocumentFolder(filename: String, dictionary: NSMutableDictionary) {
        let path:String = documents().stringByAppendingPathComponent("\(filename).plist")
        dictionary.write(toFile: path, atomically:true)
    }
    
    @objc class func readDictionaryPlistFromDocumentFolder(_ filename: String) -> NSMutableDictionary? {
        let path:String = documents().stringByAppendingPathComponent("\(filename).plist")
        if let dictionary: NSMutableDictionary = NSMutableDictionary(contentsOfFile: path) {
            return dictionary
        }
        return nil;
    }
}
