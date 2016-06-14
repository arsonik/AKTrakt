//
//  Extensions.swift
//  Pods
//
//  Created by Florian Morello on 26/05/16.
//
//

import Foundation

/// Key: Value typealias dictionary
public typealias JSONHash = [String: AnyObject?]

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
    DispatchQueue.main.after(
        when: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), block: closure)
}

// Get the area of a size
extension CGSize {
    var area: CGFloat {
        return width * height
    }
}
