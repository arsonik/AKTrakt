//
//  TraktSeason.swift
//  Arsonik
//
//  Created by Florian Morello on 15/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation

public class TraktSeason : TraktWatchable {
	
	weak var show:TraktShow!
	
	let number:Int!
	var episodes:[TraktEpisode] = []
	
	override init?(data:[String:AnyObject]!){
		if let n = data?["number"] as? Int {
			number = n
			super.init(data: data)
		}
		else {
			number = nil
			super.init(data: nil)
			return nil
		}
	}
	
	var notCompleted:[TraktEpisode] {
		return episodes.filter {$0.completed == false}
	}
	
	public override var description:String {
		return "TraktSeason(\(number)) \(episodes.count-notCompleted.count)/\(episodes.count)"
	}
}
