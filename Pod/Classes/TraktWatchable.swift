//
//  TraktWatchable.swift
//  Arsonik
//
//  Created by Florian Morello on 04/10/15.
//  Copyright © 2015 Florian Morello. All rights reserved.
//

import Foundation

class TraktWatchable: TraktObject {

    var title:String!
    var overview:String!
    var watched:Bool = false
    var watchlist:Bool = false

    override init?(data: [String : AnyObject]!) {
        overview = data?["overview"] as? String
        title = data?["title"] as? String

        super.init(data: data)
    }
}