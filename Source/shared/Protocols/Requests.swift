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
