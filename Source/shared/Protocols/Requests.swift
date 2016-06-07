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
public protocol Watchlist: ListType, ObjectType {
    /// boolean indicating if the object is in watchlist
    var watchlist: Bool? { get set }
}

/// Define a trending protocol for TraktObject
public protocol Trending: ListType, ObjectType {
}

/// Define a Recommandable protocol for TraktObject
public protocol Recommandable: ListType, ObjectType {
}

/// Define a credits protocol for TraktObject
public protocol Credits: ListType, ObjectType {
}

/// Define a searchable protocol for TraktObject
public protocol Searchable: ObjectType {
}

/// Define a list protocol for TraktObject
public protocol ListType {
    static var listName: String { get }
}

/// Define an object protocol for TraktObject
public protocol ObjectType {
    static var objectName: String { get }
}
