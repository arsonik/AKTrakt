//
//  Watchlist.swift
//  Pods
//
//  Created by Florian Morello on 27/05/16.
//
//

import Foundation
import Alamofire

public class TraktRequestGetWatchlistMovies: TraktRequest, TraktRequest_Completion {
    public init(extended: TraktRequestExtendedOptions? = nil, sort: TraktSortHeaders? = nil) {
        super.init(path: "/sync/watchlist/movies", tokenRequired: true, params: extended?.value(), headers: sort?.value())
    }

    public func request(trakt: Trakt, completion: ([(listedAt: NSDate, movie: TraktMovie)]?, NSError?) -> Void) throws -> Request? {
        return try trakt.request(self) { response in
            guard let entries = response.result.value as? [JSONHash] else {
                return completion(nil, response.result.error)
            }

            completion(entries.flatMap {
                guard let date = $0["listed_at"] as? String,
                    listedAt = Trakt.datetimeFormatter.dateFromString(date),
                    movie = TraktMovie(data: $0["movie"] as? JSONHash) else {
                        return nil
                }
                return (listedAt: listedAt, movie: movie)
                }, nil)
        }
    }
}

public class TraktRequestGetWatchlistShows: TraktRequest, TraktRequest_Completion {
    public init(extended: TraktRequestExtendedOptions? = nil, sort: TraktSortHeaders? = nil) {
        super.init(path: "/sync/watchlist/shows", tokenRequired: true, params: extended?.value(), headers: sort?.value())
    }

    public func request(trakt: Trakt, completion: ([(listedAt: NSDate, show: TraktShow)]?, NSError?) -> Void) throws -> Request? {
        return try trakt.request(self) { response in
            guard let entries = response.result.value as? [JSONHash] else {
                return completion(nil, response.result.error)
            }

            completion(entries.flatMap {
                guard let date = $0["listed_at"] as? String,
                    listedAt = Trakt.datetimeFormatter.dateFromString(date),
                    movie = TraktShow(data: $0["show"] as? JSONHash) else {
                        return nil
                }
                return (listedAt: listedAt, show: movie)
                }, nil)
        }
    }
}

public class TraktRequestGetWatchedMovies: TraktRequest, TraktRequest_Completion {
    public init(extended: TraktRequestExtendedOptions? = nil) {
        super.init(path: "/sync/watched/movies", tokenRequired: true, params: extended?.value())
    }

    public func request(trakt: Trakt, completion: ([(plays: UInt, lastWatchedAt: NSDate, movie: TraktMovie)]?, NSError?) -> Void) throws -> Request? {
        return try trakt.request(self) { response in
            guard let entries = response.result.value as? [JSONHash] else {
                return completion(nil, response.result.error)
            }
            completion(entries.flatMap {
                guard let date = $0["last_watched_at"] as? String,
                    lastWatchedAt = Trakt.datetimeFormatter.dateFromString(date),
                    plays = $0["plays"] as? UInt,
                    movie = TraktMovie(data: $0["movie"] as? JSONHash) else {
                        return nil
                }
                return (plays: plays, lastWatchedAt: lastWatchedAt, movie: movie)
            }, nil)
        }
    }
}

public class TraktRequestGetWatchedShows: TraktRequest, TraktRequest_Completion {
    public init(extended: TraktRequestExtendedOptions? = nil) {
        super.init(path: "/sync/watched/shows", tokenRequired: true, params: extended?.value())
    }

    public func request(trakt: Trakt, completion: ([(plays: UInt, lastWatchedAt: NSDate, show: TraktShow, seasons: [(season: TraktSeason, episodes: [(episode: TraktEpisode, plays: UInt, lastWatchedAt: NSDate)])]?)]?, NSError?) -> Void) throws -> Request? {
        return try trakt.request(self) { response in
            guard let entries = response.result.value as? [JSONHash] else {
                return completion(nil, response.result.error)
            }
            completion(entries.flatMap {
                guard let date = $0["last_watched_at"] as? String,
                    lastWatchedAt = Trakt.datetimeFormatter.dateFromString(date),
                    plays = $0["plays"] as? UInt,
                    show = TraktShow(data: $0["show"] as? JSONHash) else {
                        return nil
                }
                return (plays: plays, lastWatchedAt: lastWatchedAt, show: show, seasons: ($0["seasons"] as? [JSONHash])?.flatMap {
                    guard let season = TraktSeason(data: $0),
                        episodesData = $0["episodes"] as? [JSONHash]
                        else {
                            return nil
                    }
                    return (season: season, episodes: episodesData.flatMap({
                        guard let episode = TraktEpisode(data: $0),
                            date = $0["last_watched_at"] as? String,
                            plays = $0["plays"] as? UInt,
                            lastWatchedAt = Trakt.datetimeFormatter.dateFromString(date) else {
                                return nil
                        }
                        return (episode: episode, plays: plays, lastWatchedAt: lastWatchedAt)
                    }))
                    })
                }, nil)
        }
    }
}

public class TraktRequestAddToHistory: TraktRequest, TraktRequest_Completion {
    public init(list: [TraktType: [(traktId: TraktIdentifier, watchedAt: NSDate)]]) {
        var params: JSONHash = [:]
        list.forEach { type, values in
            params[type.rawValue] = values.flatMap { value in
                [
                    "watched_at": Trakt.datetimeFormatter.stringFromDate(value.watchedAt),
                    "ids": [
                        "trakt": value.traktId
                    ],
                ]
            }
        }
        super.init(method: "POST", path: "/sync/history", params: params, tokenRequired: true)
    }

    public func request(trakt: Trakt, completion: ((added: [TraktType: Int]?, notFound: [TraktType: [TraktIdentifier]]?)?, NSError?) -> Void) throws -> Request? {
        return try trakt.request(self) { response in
            guard let items = response.result.value as? JSONHash, added = items["added"] as? [String: Int], notFound = items["not_found"] as? [String: [JSONHash]] else {
                return completion(nil, response.result.error)
            }

            var aItems: [TraktType: Int]? = [:]
            var nItems: [TraktType: [TraktIdentifier]]? = [:]
            added.forEach {
                guard let type = TraktType(rawValue: $0.0) where $0.1 > 0 else {
                    return
                }
                aItems?[type] = $0.1
            }
            if aItems?.count == 0 {
                aItems = nil
            }
            notFound.forEach {
                guard let type = TraktType(rawValue: $0.0) else {
                    return
                }
                nItems?[type] = $0.1.flatMap { object in
                    (object["ids"] as? [String: Int])?["trakt"]
                }
                if nItems?[type]?.count == 0 {
                    nItems?.removeValueForKey(type)
                }
            }
            if nItems?.count == 0 {
                nItems = nil
            }
            completion((added: aItems, notFound: nItems), response.result.error)
        }
    }
}

public class TraktRequestAddToWatchlist: TraktRequest, TraktRequest_Completion {
    public init(list: [TraktType: [TraktIdentifier]]) {
        var params: JSONHash = [:]
        list.forEach { type, values in
            params[type.rawValue] = values.flatMap { value in
                [
                    "ids": [
                        "trakt": value
                    ],
                ]
            }
        }
        super.init(method: "POST", path: "/sync/watchlist", params: params, tokenRequired: true)
    }

    public func request(trakt: Trakt, completion: ((added: [TraktType: Int]?, existing: [TraktType: Int]?, notFound: [TraktType: [TraktIdentifier]]?)?, NSError?) -> Void) throws -> Request? {
        return try trakt.request(self) { response in
            guard let items = response.result.value as? JSONHash,
                added = items["added"] as? [String: Int],
                existing = items["existing"] as? [String: Int],
                notFound = items["not_found"] as? [String: [JSONHash]] else {
                return completion(nil, response.result.error)
            }

            var aItems: [TraktType: Int]? = [:]
            var eItems: [TraktType: Int]? = [:]
            var nItems: [TraktType: [TraktIdentifier]]? = [:]
            added.forEach {
                guard let type = TraktType(rawValue: $0.0) where $0.1 > 0 else {
                    return
                }
                aItems?[type] = $0.1
            }
            if aItems?.count == 0 {
                aItems = nil
            }
            existing.forEach {
                guard let type = TraktType(rawValue: $0.0) where $0.1 > 0 else {
                    return
                }
                eItems?[type] = $0.1
            }
            if eItems?.count == 0 {
                eItems = nil
            }
            notFound.forEach {
                guard let type = TraktType(rawValue: $0.0) else {
                    return
                }
                nItems?[type] = $0.1.flatMap { object in
                    (object["ids"] as? [String: Int])?["trakt"]
                }
                if nItems?[type]?.count == 0 {
                    nItems?.removeValueForKey(type)
                }
            }
            if nItems?.count == 0 {
                nItems = nil
            }
            completion((added: aItems, existing: eItems, notFound: nItems), response.result.error)
        }
    }
}
