//
//  TraktRequest.swift
//  Pods
//
//  Created by Florian Morello on 25/05/16.
//
//

import Foundation

// Define a protocol request used by the api
public protocol TraktRequest {
    var path: String { get }
    var params: JSONHash? { get }
}

// Define a GET request
public protocol TraktRequestGET: TraktRequest {}

// Define a POST request
public protocol TraktRequestPOST: TraktRequest {}

// Define a DELETE request
public protocol TraktRequestDELETE: TraktRequest {}

// Define a request that need a logged user
public protocol TraktRequestLogged {}

// Define a request that should not be retried on failure
public protocol TraktRequestOnlyOnce {}

// Define a request that can have extended arguments like (full, images)
public protocol TraktRequestExtended {
    var extendedInfo: [TraktRequestExtendedInfo]? { get }
}

public struct TraktRequestExtendedInfo: OptionSetType {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    static let None = TraktRequestExtendedInfo(rawValue: 0)
    static let Images = TraktRequestExtendedInfo(rawValue: 1 << 0)
    static let Full = TraktRequestExtendedInfo(rawValue: 1 << 1)
    static let Metadata = TraktRequestExtendedInfo(rawValue: 1 << 2)
}
