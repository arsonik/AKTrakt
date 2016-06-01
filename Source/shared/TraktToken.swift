//
//  TraktToken.swift
//  Arsonik
//
//  Created by Florian Morello on 10/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation

/// Represents a trakt token
public class TraktToken {
    internal static var userDefaultsTokenKey = "traktToken"
    /// The access token
    public let accessToken: String!
    /// Expiration date
    public let expiresAt: NSDate!
    /// Refresh value
    public let refreshToken: String!
    /// Token's type
    public let tokenType: String!
    /// Token's scope
    public let scope: String!

    /**
     Init a token

     - parameter accessToken:  accessToken
     - parameter expiresAt:    expiresAt
     - parameter refreshToken: refreshToken
     - parameter tokenType:    tokenType
     - parameter scope:        scope
     */
    init(accessToken: String, expiresAt: NSDate, refreshToken: String, tokenType: String, scope: String) {
        self.accessToken = accessToken
        self.expiresAt = expiresAt
        self.refreshToken = refreshToken
        self.tokenType = tokenType
        self.scope = scope
    }

    /**
     Init with data
     - parameter data: JSONHash
     */
    convenience init?(data: JSONHash!) {
        guard let token = data,
            accessToken = token["access_token"] as? String,
            expiresIn = token["expires_in"] as? Double,
            scope = token["scope"] as? String,
            tokenType = token["token_type"] as? String,
            refreshToken = token["refresh_token"] as? String else {
                return nil
        }
        self.init(accessToken: accessToken, expiresAt: NSDate(timeIntervalSinceNow: expiresIn), refreshToken: refreshToken, tokenType: tokenType, scope: scope)
    }

    /**
     Attemps to load token from NSUserDefaults

     - parameter clientId: clientId

     - returns: TraktToken
     */
    internal static func load(clientId: String) -> TraktToken? {
        let defaults = NSUserDefaults.standardUserDefaults()
        guard let data = defaults.objectForKey(TraktToken.userDefaultsTokenKey + clientId) as? JSONHash else {
            return nil
        }
        return TraktToken(data: data)
    }

    /**
     Save token to NSUserDefaults

     - parameter clientId: clientId
     */
    internal func save(clientId: String!) {
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: TraktToken.userDefaultsTokenKey + clientId)
    }

    /**
     Remove token from NSUserDefaults

     - parameter clientId: clientId
     */
    internal func remove(clientId: String!) {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(TraktToken.userDefaultsTokenKey + clientId)
    }

    /// Give a JSONHash represenation of the token
    private var data: JSONHash {
        return [
            "access_token": accessToken,
            "token_type": tokenType,
            "expires_in": expiresAt.timeIntervalSinceNow,
            "refresh_token": refreshToken,
            "scope": scope
        ]
    }
}
