//
//  String.swift
//  AKTrakt
//
//  Created by Florian Morello on 30/10/15.
//  Copyright © 2015 Florian Morello. All rights reserved.
//

import Foundation

extension String {
    var slug:String {
        var cp = self.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        // remove accents
        cp = cp.stringByFoldingWithOptions(NSStringCompareOptions.DiacriticInsensitiveSearch, locale: NSLocale.currentLocale())
        cp = cp.stringByReplacingOccurrencesOfString(" ", withString: "-", options: NSStringCompareOptions.LiteralSearch, range: nil)
        cp = cp.stringByReplacingOccurrencesOfString("'", withString: "-", options: NSStringCompareOptions.LiteralSearch, range: nil)
        return cp
    }
}