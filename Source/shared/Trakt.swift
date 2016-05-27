//
//  Trakt.swift
//  Arsonik
//
//  Created by Florian Morello on 08/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation
import Alamofire

/// Main Class
public class Trakt {
    // Client Id
    public let clientId: String

    // Application Secret
    internal let clientSecret: String

    // Application Id
    internal let applicationId: Int

    // Trakt Token
    internal var token: TraktToken?

    /// Delay between each attempt
    internal var retryInterval: Double = 5

    // Cache request attempts (in case of faileur/retry)
    internal var attempts = NSCache()

    /// Number of attempt after getting 500 errors
    internal var maximumAttempt: Int = 6

    // Alamofire Manager
    internal let manager: Manager

    // Trakt api version
    public let traktApiVersion = 2


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

    public func hasValidToken() -> Bool {
        return token != nil
    }

    public func clearToken() {
        token?.remove(clientId)
        token = nil
    }

    public func saveToken(token: TraktToken) {
        token.save(clientId)
        self.token = token
    }

    public static let dateFormatter: NSDateFormatter = {
        let df = NSDateFormatter()
        df.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        df.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        df.dateFormat = "yyyy'-'MM'-'dd"
        return df
    }()

    public static let datetimeFormatter: NSDateFormatter = {
        let df = NSDateFormatter()
        df.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        df.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        df.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.000Z'"
        return df
    }()
}
