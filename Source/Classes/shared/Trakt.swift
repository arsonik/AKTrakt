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
    internal let clientId: String

    // Application Secret
    internal let clientSecret: String

    // Application Id
    internal let applicationId: Int

    // Trakt Token
    private var token: TraktToken?

    /// Delay between each attempt
    internal var retryInterval: Double = 5

    // Cache request attempts (in case of faileur/retry)
    private var attempts = NSCache()

    /// Number of attempt after getting 500 errors
    internal var maximumAttempt: Int = 6

    // Alamofire Manager
    private let manager: Manager

    // Trakt api version
    public let traktApiVersion = 2

    public typealias GeneratedCodeResponse = (deviceCode: String, userCode: String, verificationUrl: String, expiresAt: NSDate, interval: NSTimeInterval)

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

    internal func query(route: TraktRoute, completionHandler: Response<AnyObject, NSError> -> Void) -> Request! {
        let request = route.URLRequest
        request.setValue("\(traktApiVersion)", forHTTPHeaderField: "trakt-api-version")
        request.setValue(clientId, forHTTPHeaderField: "trakt-api-key")

        if route.needAuthorization() {
            if let accessToken = token?.accessToken {
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            } else {
                print("You need an access token that call that resource")
                return nil
            }
        }

        let key = route.hashValue
        return manager.request(request).responseJSON { [weak self] response in
            guard let ss = self else {
                completionHandler(response)
                return
            }
            if response.response?.statusCode >= 500 && route.retryOnFailure() {
                var attempt: Int = ss.attempts.objectForKey(key) as? Int ?? 0
                attempt += 1
                ss.attempts.setObject(attempt, forKey: key)
                if attempt < ss.maximumAttempt {
                    // try again after delay
                    return delay(ss.retryInterval) {
                        ss.query(route, completionHandler: completionHandler)
                    }
                } else {
                    print("Maximum attempt \(attempt)/\(ss.maximumAttempt) reached for request \(route)")
                }
            }
            ss.attempts.removeObjectForKey(key)
            completionHandler(response)
        }
    }
}
