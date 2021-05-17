//
//  IJReachability.swift
//  IJReachability
//
//  Created by Isuru Nanayakkara on 1/14/15.
//  Copyright (c) 2015 Appex. All rights reserved.
//
import Foundation
import SystemConfiguration

public enum IJReachabilityType {
    case wwan,
    wiFi,
    notConnected
}


struct NetworkStatusConstants  {
    static let kNetworkAvailabilityStatusChangeNotification = "kNetworkAvailabilityStatusChangeNotification"
    static let Status = "Status"
    static let Offline = "Offline"
    static let Online = "Online"
    static let Unknown = "Unknown"
}

/// With thanks to http://stackoverflow.com/questions/25623272/how-to-use-scnetworkreachability-in-swift/25623647#25623647

open class IJReachability {

    /**
     :see: Original post - http://www.chrisdanielson.com/2009/07/22/iphone-network-connectivity-test-example/
     */
    open class func isConnectedToNetwork() -> Bool {

        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)

        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }) else {
            return false
        }

        var flags: SCNetworkReachabilityFlags = []

        if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == false {
            return false
        }

        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)

        return isReachable && !needsConnection
    }

    open class func isConnectedToNetworkOfType() -> IJReachabilityType {


        //MARK: - TODO Check this when I have an actual iOS 9 device.
        if !self.isConnectedToNetwork() {
            return .notConnected
        }

        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)

        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }) else {
            return .notConnected
        }

        var flags: SCNetworkReachabilityFlags = []

        if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == false {
            return .notConnected
        }

        let isReachable = flags.contains(.reachable)
        let isWWAN = flags.contains(.isWWAN)

        if isReachable && isWWAN {
            return .wwan
        }

        if isReachable && !isWWAN {
            return .wiFi
        }

        return .notConnected
    }



    ///
    /// Usage:
    ///
    /// Setup
    ///
    ///
    ///        NSNotificationCenter.defaultCenter().addObserver(self,
    ///          selector: "networkStatusDidChange:",
    ///          name: NetworkStatusConstants.kNetworkAvailabilityStatusChangeNotification,
    ///          object: nil)
    ///
    ///
    ///        IJReachability.monitorNetworkChanges()
    ///
    /// Callback
    ///
    ///         func networkStatusDidChange(notification: NSNotification) {
    ///             let networkStatus = notification.userInfo?[ NetworkStatusConstants.Status]
    ///             print("\(networkStatus)")
    ///         }
    ///
    ///

    class func monitorNetworkChanges() {

        let host = "google.com"
        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        let reachability = SCNetworkReachabilityCreateWithName(nil, host)!

        SCNetworkReachabilitySetCallback(reachability, { (_, flags, _) in

            let status:String?

            if !flags.contains(SCNetworkReachabilityFlags.connectionRequired) && flags.contains(SCNetworkReachabilityFlags.reachable) {
                status = NetworkStatusConstants.Online
            } else {
                status =  NetworkStatusConstants.Offline
            }

            NotificationCenter.default.post(name: Notification.Name(rawValue: NetworkStatusConstants.kNetworkAvailabilityStatusChangeNotification),
                                            object: nil,
                                            userInfo: [NetworkStatusConstants.Status: status!])

        }, &context)

        SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetMain(), CFRunLoopMode.commonModes as! CFString)
    }
}
