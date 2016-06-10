//
//  Trakt.swift
//  Arsonik
//
//  Created by Florian Morello on 08/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation
import Alamofire

/// Trakt client
public class Trakt {
    // Client Id
    public let clientId: String
    // Application Secret
    internal let clientSecret: String
    // Application Id
    internal let applicationId: Int
    // Trakt Token
    public var token: TraktToken?
    /// Delay between each re attempt in seconds
    internal var retryInterval: Double = 5
    // Cache request attempts (in case of faileur/retry)
    internal var attempts = NSCache()
    // Alamofire Manager
    internal let manager = Manager()
    // Trakt api version
    public let traktApiVersion = 2
    // NSUserDefaults key
    private var userDefaultsTokenKey: String

    /**
     Init

     - parameter clientId:      clientId
     - parameter clientSecret:  clientSecret
     - parameter applicationId: applicationId
     */
    public init(clientId: String, clientSecret: String, applicationId: Int) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.applicationId = applicationId
        userDefaultsTokenKey = "trakt_token_" + clientId

        // autoload token
        token = loadTokenFromDefaults()
    }

    /**
     Attempt to load token from NSUserDefaults

     - returns: TraktToken
     */
    private func loadTokenFromDefaults() -> TraktToken? {
        let defaults = NSUserDefaults.standardUserDefaults()
        guard let data = defaults.objectForKey(userDefaultsTokenKey) as? NSData,
            token = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? TraktToken else {
            return nil
        }
        return token
    }

    /**
     Save token

     - parameter token: TraktToken
     */
    public func saveToken(token: TraktToken) {
        self.token = token

        let data = NSKeyedArchiver.archivedDataWithRootObject(token)
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: userDefaultsTokenKey)
    }

    /// Remove token from NSUserDefaults
    public func clearToken() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(userDefaultsTokenKey)
        token = nil
    }

    /**
     Check if client has a non expired token

     - returns: bool
     */
    public func hasValidToken() -> Bool {
        return token?.expiresAt.compare(NSDate()) == .OrderedDescending
    }

    /// Date formatter (trakt style)
    public static let dateFormatter: NSDateFormatter = {
        let df = NSDateFormatter()
        df.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        df.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        df.dateFormat = "yyyy'-'MM'-'dd"
        return df
    }()

    /// Datetime formatter (trakt style)
    public static let datetimeFormatter: NSDateFormatter = {
        let df = NSDateFormatter()
        df.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        df.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        df.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.000Z'"
        return df
    }()
}
