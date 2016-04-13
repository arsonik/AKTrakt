//
//  TraktWatchable.swift
//  Arsonik
//
//  Created by Florian Morello on 04/10/15.
//  Copyright © 2015 Florian Morello. All rights reserved.
//

import Foundation

public class TraktWatchable: TraktObject {

    public var title: String?
    public var overview: String?
    public var watched: Bool = false
    public var watchlist: Bool = false

	override public func digest(data: [String : AnyObject]?) {
		super.digest(data)

		title = data?["title"] as? String ?? title
		overview = data?["overview"] as? String ?? overview
	}
}
