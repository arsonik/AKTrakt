//
//  TraktSeason.swift
//  Arsonik
//
//  Created by Florian Morello on 15/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation

public class TraktSeason: TraktWatchable {

	public weak var show: TraktShow?

	public var number: Int!

	private var _episodes: [TraktEpisode] = []
	public var episodes: [TraktEpisode] {
		return _episodes
	}

	public override func digest(data: [String : AnyObject]?) {
		super.digest(data)

		number = data?["number"] as? Int ?? number
	}

	public var notCompleted: [TraktEpisode] {
		return episodes.filter {$0.watched == false}
	}

	public func addEpisode(episode: TraktEpisode) {
		episode.season = self
		episode.seasonNumber = self.number
		_episodes.append(episode)
	}

	public override var description: String {
		return "TraktSeason(\(number)) \(episodes.count-notCompleted.count)/\(episodes.count)"
	}
}
