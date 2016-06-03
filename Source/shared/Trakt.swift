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
    internal var token: TraktToken?
    /// Delay between each re attempt in seconds
    internal var retryInterval: Double = 5
    // Cache request attempts (in case of faileur/retry)
    internal var attempts = NSCache()
    // Alamofire Manager
    internal let manager: Manager
    // Trakt api version
    public let traktApiVersion = 2

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

        manager = Manager()

        // autoload token
        if let storedToken = TraktToken.load(clientId) {
            token = storedToken
        }
    }

    /**
     Check if client has a current valid token

     - returns: bool
     */
    public func hasValidToken() -> Bool {
        return token != nil
    }

    /// Clear current token
    public func clearToken() {
        token?.remove(clientId)
        token = nil
    }

    /**
     Save token

     - parameter token: token
     */
    public func saveToken(token: TraktToken) {
        token.save(clientId)
        self.token = token
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
