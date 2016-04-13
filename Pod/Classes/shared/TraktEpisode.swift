//
//  TraktEpisode.swift
//  Arsonik
//
//  Created by Florian Morello on 15/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation

public class TraktEpisode: TraktWatchable {

	public weak var season: TraktSeason?

	public var number: Int!
	public var seasonNumber: Int?
	public var loaded: Bool? = false
	public var firstAired: NSDate?

	override public func digest(data: [String : AnyObject]!) {
		super.digest(data)

		number = data?["number"] as? Int ?? number
		seasonNumber = data?["season"] as? Int ?? seasonNumber
		watched = data?["completed"] as? Bool ?? watched
		if let fa = data["first_aired"] as? String, date = TraktObject.timeFormatter.dateFromString(fa) {
			firstAired = date
		}
	}

	public override var description: String {
		return "TraktEpisode id\(id) \(season?.title) \(seasonNumber):\(number)) completed \(watched)"
	}
}
