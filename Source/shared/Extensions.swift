//
//  Extensions.swift
//  Pods
//
//  Created by Florian Morello on 26/05/16.
//
//

import Foundation

public typealias JSONHash = [String: AnyObject!]

internal func delay(delay: Double, closure: ()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

extension CGSize {
    var area: CGFloat {
        return width * height
    }
}

public extension String {
    var slug: String {
        var cp = self.lowercaseString.stringByTrimmingCharactersInSet(.whitespaceCharacterSet())
        cp = cp.stringByTrimmingCharactersInSet(.illegalCharacterSet())
        cp = cp.stringByTrimmingCharactersInSet(.symbolCharacterSet())
        // remove accents
        cp = cp.stringByFoldingWithOptions(NSStringCompareOptions.DiacriticInsensitiveSearch, locale: NSLocale.currentLocale())
        cp = cp.stringByReplacingOccurrencesOfString(" ", withString: "-", options: NSStringCompareOptions.LiteralSearch, range: nil)
        cp = cp.stringByReplacingOccurrencesOfString("'", withString: "-", options: NSStringCompareOptions.LiteralSearch, range: nil)
        return cp
    }
}

extension NSURLRequest {
    public func hashDescription() -> String {

        var result = "" + (HTTPMethod ?? "nil") + "; (URL); timeoutInterval=" + String(format: "%.1fs", timeoutInterval) + "> {"

        // Add header fields.
        if let headers = allHTTPHeaderFields {
            result += "\nallHTTPHeaderFields {"
            for (key, value) in headers {
                result += "\n\t\(key) : '\(value)'"
            }
            result += "\n}"
        }

        if let body = HTTPBody {
            result += "\nHTTPBody {\n " + ((NSString(data: body, encoding: NSASCIIStringEncoding) ?? "") as String) + "}"
        }

        return result + "\n}"
    }
}