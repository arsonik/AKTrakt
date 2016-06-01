//
//  Requests.swift
//  Pods
//
//  Created by Florian Morello on 01/06/16.
//
//

import Foundation

/// Define a protocol for URL Parameters
public protocol TraktURLParameters {
    func value() -> JSONHash
}

/// Define a protocol for HTTP Request Headers
public protocol TraktRequestHeaders {
    func value() -> [String: String]
}

/// Define a watchlist protocol for TraktObject
public protocol Watchlist: ListName, ObjectName {}

/// Define a trending protocol for TraktObject
public protocol Trending: ListName, ObjectName {
}

/// Define a list protocol for TraktObject
public protocol ListName {
    static var listName: String { get }
}

/// Define an object protocol for TraktObject
public protocol ObjectName {
    static var objectName: String { get }
}
