//
//  TraktMovie.swift
//  Arsonik
//
//  Created by Florian Morello on 15/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation

/// 🎥 TraktMovie
public class TraktMovie: TraktWatchable, Castable {

    /// Youtube video name ex: _1MDrwqjeGo
    public var trailer: String?
    /// Rating between 0-10
    public var rating: Float?
    /// Number of votes
    public var votes: Int?
    /// Production year
    public var year: Int?
    /// Release date
    public var release: NSDate?
    /// Length in minutes
    public var runtime: Int?
    /// Array of genres
    public var genres: [String]?

    /// Array of TraktCrew
    public var crew: [TraktCrew]?
    /// Array of TraktCharacter
    public var casting: [TraktCharacter]?

    /// Array of TraktRelease
    public var releases: [TraktRelease]?

    public var type: TraktType {
        return .Movies
    }

    override public func digest(data: JSONHash?) {
        super.digest(data)

        rating = data?["rating"] as? Float ?? rating
        votes = data?["votes"] as? Int ?? votes
        year = data?["year"] as? Int ?? year
        genres = data?["genres"] as? [String] ?? genres
        runtime = data?["runtime"] as? Int ?? runtime

        if let r = data?["released"] as? String, d = Trakt.dateFormatter.dateFromString(r) {
            release = d
        }

        if let x = data?["trailer"] as? String, url = NSURL(string: x), params = url.query?.componentsSeparatedByString("v=") where params.count == 2 {
            trailer = params[1]
        }
    }
}
