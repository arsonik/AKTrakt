//
//  TraktMovie.swift
//  Arsonik
//
//  Created by Florian Morello on 15/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation

/// Represents a movie
public class TraktMovie: TraktObject, Descriptable, Watchable, Collectable, Trending, Watchlist, Credits, Searchable, Recommandable {
    /// Youtube video name ex: _1MDrwqjeGo
    public var trailer: String?
    /// Rating between 0-10
    public var rating: Float?
    /// Number of votes
    public var votes: Int?
    /// Production year
    public var year: Int?
    /// Release date
    public var release: Date?
    /// Length in minutes
    public var runtime: Int?
    /// Array of genres
    public var genres: [String]?
    /// Array of TraktRelease
    public var releases: [TraktRelease]?
    /// Descriptable conformance
    public var title: String?
    /// Descriptable conformance
    public var overview: String?
    /// Watchable conformance
    public var watched: Bool?
    /// Watchlist conformance
    public var watchlist: Bool?
    /// Watchable conformance
    public var lastWatchedAt: Date? = nil
    /// Watchable conformance
    public var plays: UInt?
    /// Collectable conformance
    public var collectedAt: Date?

    /**
     Digest data

     - parameter data: data
     */
    override public func digest(_ data: JSONHash?) {
        super.digest(data)

        rating = data?["rating"] as? Float ?? rating
        votes = data?["votes"] as? Int ?? votes
        year = data?["year"] as? Int ?? year
        genres = data?["genres"] as? [String] ?? genres
        runtime = data?["runtime"] as? Int ?? runtime

        if let r = data?["released"] as? String, let d = Trakt.dateFormatter.date(from: r) {
            release = d
        }

        if let x = data?["trailer"] as? String, let url = URL(string: x), let params = url.query?.components(separatedBy: "v="), params.count == 2 {
            trailer = params[1]
        }
    }

    public static var listName: String {
        return "movies"
    }

    public static var objectName: String {
        return "movie"
    }

    /// CustomStringConvertible conformance
    public override var description: String {
        return "TraktMovie(\(title))"
    }
}
