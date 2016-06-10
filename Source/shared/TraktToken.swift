//
//  TraktToken.swift
//  Arsonik
//
//  Created by Florian Morello on 10/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation

/// Represents a trakt token
@objc public class TraktToken: NSObject, NSCoding {
    /// The access token
    public let accessToken: String
    /// Expiration date
    public let expiresAt: NSDate
    /// Refresh value
    public let refreshToken: String
    /// Token's type
    public let tokenType: String
    /// Token's scope
    public let scope: String

    /**
     Init a token

     - parameter accessToken:  accessToken
     - parameter expiresAt:    expiresAt
     - parameter refreshToken: refreshToken
     - parameter tokenType:    tokenType
     - parameter scope:        scope
     */
    public init(accessToken: String, expiresAt: NSDate, refreshToken: String, tokenType: String, scope: String) {
        self.accessToken = accessToken
        self.expiresAt = expiresAt
        self.refreshToken = refreshToken
        self.tokenType = tokenType
        self.scope = scope
    }

    /**
     Init with a JSONHash

     - parameter data: JSONHash
     */
    convenience init?(data: JSONHash?) {
        guard let accessToken = data?["access_token"] as? String,
            expiresIn = data?["expires_in"] as? Double,
            scope = data?["scope"] as? String,
            tokenType = data?["token_type"] as? String,
            refreshToken = data?["refresh_token"] as? String else {
                return nil
        }
        self.init(accessToken: accessToken, expiresAt: NSDate(timeIntervalSinceNow: expiresIn), refreshToken: refreshToken, tokenType: tokenType, scope: scope)
    }

    /// NSCoding
    public required init?(coder aDecoder: NSCoder) {
        guard let accessToken = aDecoder.decodeObjectForKey("accessToken") as? String,
        tokenType = aDecoder.decodeObjectForKey("tokenType") as? String,
        expiresAt = aDecoder.decodeObjectForKey("expiresAt") as? NSDate,
        refreshToken = aDecoder.decodeObjectForKey("refreshToken") as? String,
            scope = aDecoder.decodeObjectForKey("scope") as? String else {
                return nil
        }

        print(accessToken)
        print(expiresAt)
        print(refreshToken)
        print(tokenType)
        print(scope)
        self.accessToken = accessToken
        self.expiresAt = expiresAt
        self.refreshToken = refreshToken
        self.tokenType = tokenType
        self.scope = scope
    }

    /// NSCoding
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(accessToken, forKey: "accessToken")
        aCoder.encodeObject(tokenType, forKey: "tokenType")
        aCoder.encodeObject(expiresAt, forKey: "expiresAt")
        aCoder.encodeObject(refreshToken, forKey: "refreshToken")
        aCoder.encodeObject(scope, forKey: "scope")
    }
}
