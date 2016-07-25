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
    public let expiresAt: Date
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
    public init(accessToken: String, expiresAt: Date, refreshToken: String, tokenType: String, scope: String) {
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
            let expiresIn = data?["expires_in"] as? Double,
            let scope = data?["scope"] as? String,
            let tokenType = data?["token_type"] as? String,
            let refreshToken = data?["refresh_token"] as? String else {
                return nil
        }
        self.init(accessToken: accessToken, expiresAt: Date(timeIntervalSinceNow: expiresIn), refreshToken: refreshToken, tokenType: tokenType, scope: scope)
    }

    /// NSCoding
    public required init?(coder aDecoder: NSCoder) {
        guard let accessToken = aDecoder.decodeObject(forKey: "accessToken") as? String,
        let tokenType = aDecoder.decodeObject(forKey: "tokenType") as? String,
        let expiresAt = aDecoder.decodeObject(forKey: "expiresAt") as? Date,
        let refreshToken = aDecoder.decodeObject(forKey: "refreshToken") as? String,
        let scope = aDecoder.decodeObject(forKey: "scope") as? String else {
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
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(accessToken, forKey: "accessToken")
        aCoder.encode(tokenType, forKey: "tokenType")
        aCoder.encode(expiresAt, forKey: "expiresAt")
        aCoder.encode(refreshToken, forKey: "refreshToken")
        aCoder.encode(scope, forKey: "scope")
    }
}
