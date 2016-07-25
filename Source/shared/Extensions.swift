//
//  Extensions.swift
//  Pods
//
//  Created by Florian Morello on 26/05/16.
//
//

import UIKit

/// Key: Value typealias dictionary
public typealias JSONHash = [String: AnyObject]

// Allow to merge JSONHash
func += (left: inout JSONHash, right: JSONHash) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}

/**
 Delay closure

 - parameter delay:   time in seconds
 - parameter closure: closure to exec
 */
internal func delay(_ delay: Double, closure: () ->()) {
    DispatchQueue.main.after(when: .now() + delay, execute: closure)
}

// Get the area of a size
extension CGSize {
    var area: CGFloat {
        return width * height
    }
}
