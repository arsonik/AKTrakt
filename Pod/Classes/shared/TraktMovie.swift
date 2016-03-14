//
//  TraktMovie.swift
//  Arsonik
//
//  Created by Florian Morello on 15/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation

/// 🎥 TraktMovie
public class TraktMovie: TraktWatchable {

	/// Youtube video name ex: _1MDrwqjeGo
	public let trailer: String?
	/// Rating between 0-10
	public let rating: Float?
	/// Production year
	public let year: Int?
	/// Release date
    public let release: NSDate?
	/// Length in minutes
    public let runtime: Int?
	/// Array of genres
	public let genres: [String]?
	/// Array of TraktCrew
	public var crew: [TraktCrew]?
	/// Array of TraktCharacter
    public var casting: [TraktCharacter]?

	public override init?(data: [String : AnyObject]!) {
		rating = data?["rating"] as? Float
		year = data?["year"] as? Int
        genres = data?["genres"] as? [String]
        runtime = data?["runtime"] as? Int
        let df = NSDateFormatter()
        df.dateFormat = "yyyy'-'MM'-'dd"

        if let r = data?["released"] as? String, d = df.dateFromString(r) {
            release = d
        } else {
            release = nil
        }

		if let x = data?["trailer"] as? String, url = NSURL(string: x), params = url.query?.componentsSeparatedByString("v=") where params.count == 2 {
			trailer = params[1]
		} else {
			trailer = nil
		}

		super.init(data: data)
	}
}
