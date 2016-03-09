//
//  TraktEpisode.swift
//  Arsonik
//
//  Created by Florian Morello on 15/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation

public class TraktEpisode: TraktWatchable {

	public weak var season: TraktSeason!

	public let number: Int!
	public var seasonNumber: Int!

	var loaded: Bool? = false

	public var firstAired: NSDate!

	override init?(data: [String: AnyObject]!) {
		if let n = data?["number"] as? Int {
			number = n
			seasonNumber = data?["season"] as? Int
			super.init(data: data)
			if let c = data?["completed"] as? Bool {
				watched = c
			}
		} else {
			number = nil
			super.init(data: nil)
			return nil
		}
	}

	public override var description: String {
		return "TraktEpisode(\(number)) completed \(watched)"
	}
}
