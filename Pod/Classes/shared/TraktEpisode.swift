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

	public let number: Int!
	public var seasonNumber: Int?
	public var loaded: Bool? = false
	public var firstAired: NSDate?

	override init?(data: [String: AnyObject]!) {
		guard let n = data?["number"] as? Int else {
			return nil
		}
		number = n
		seasonNumber = data?["season"] as? Int
		if let fa = data?["first_aired"] as? String {
			let df = NSDateFormatter()
			df.locale = NSLocale(localeIdentifier: "en_US_POSIX")
			df.timeZone = NSTimeZone(forSecondsFromGMT: 0)
			df.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.000Z'"
			firstAired = df.dateFromString(fa)
		} else {
			firstAired = nil
		}
		super.init(data: data)

		if let c = data?["completed"] as? Bool {
			watched = c
		}
	}

	public override var description: String {
		return "TraktEpisode id\(id) \(season?.title) \(seasonNumber):\(number)) completed \(watched)"
	}
}
