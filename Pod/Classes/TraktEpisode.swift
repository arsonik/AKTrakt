//
//  TraktEpisode.swift
//  Arsonik
//
//  Created by Florian Morello on 15/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation

public class TraktEpisode : TraktWatchable {
	
	weak var season:TraktSeason!
	
	let number:Int!
	var seasonNumber:Int!
	var completed:Bool!
	
	var loaded:Bool! = false
	
	var firstAired:NSDate!
	
	override init?(data: [String:AnyObject]!){
		if let n = data?["number"] as? Int {
			number = n
			seasonNumber = data?["season"] as? Int
			completed = data?["completed"] as? Bool
			super.init(data: data)
		}
		else {
			number = nil
			super.init(data: nil)
			return nil
		}
	}
	
	override var description:String {
		return "TraktEpisode(\(number)) completed \(completed)"
	}
}