//
//  TraktError.swift
//  Pods
//
//  Created by Florian Morello on 01/06/16.
//
//

import Foundation

/**
 Represents a trakt client error type

 - TokenRequired: Cannot make request without token
 - UrlError:      Unable to prepare url
 */
public enum TraktError: ErrorProtocol {
    case tokenRequired
    case urlError
}
