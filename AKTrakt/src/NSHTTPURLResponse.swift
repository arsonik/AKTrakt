//
//  NSHTTPURLResponse.swift
//  AKTrakt
//
//  Created by Florian Morello on 30/10/15.
//  Copyright © 2015 Florian Morello. All rights reserved.
//

import Foundation

extension NSHTTPURLResponse {
    var shouldRetry: Bool {
        return statusCode == 504 || statusCode == 503
    }
}
