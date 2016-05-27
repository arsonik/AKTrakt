//
//  Sync.swift
//  Pods
//
//  Created by Florian Morello on 26/05/16.
//
//

import Foundation
import Alamofire

public class TraktRequestGetMovieCollection: TraktRequest, TraktRequest_Completion {
    public init(extended: TraktRequestExtendedOptions = .Min) {
        super.init(path: "/sync/collection/movies", params: extended.value(), oAuth: true)
    }

    public func request(trakt: Trakt, completion: ([(collectedAt: NSDate, movie: TraktMovie)]?, NSError?) -> Void) throws -> Request? {
        return try trakt.request(self) { response in
            guard let entries = response.result.value as? [JSONHash] else {
                return completion(nil, response.result.error)
            }

            let list: [(collectedAt: NSDate, movie: TraktMovie)] = entries.flatMap {
                guard let date = $0["collected_at"] as? String,
                    collectedAt = Trakt.datetimeFormatter.dateFromString(date),
                    media = TraktMovie(data: $0["movie"] as? JSONHash) else {
                        return nil
                }
                return (collectedAt: collectedAt, movie: media)
            }
            completion(list, nil)
        }
    }
}

public class TraktRequestGetShowCollection: TraktRequest, TraktRequest_Completion {
    public init(extended: TraktRequestExtendedOptions = .Min) {
        super.init(path: "/sync/collection/shows", params: extended.value(), oAuth: true)
    }

    public func request(trakt: Trakt, completion: ([(lastCollectedAt: NSDate, show: TraktShow, seasons: [(season: TraktSeason, episodes: [(episode: TraktEpisode, collectedAt: NSDate)])]?)]?, NSError?) -> Void) throws -> Request? {
        return try trakt.request(self) { response in
            guard let entries = response.result.value as? [JSONHash] else {
                return completion(nil, response.result.error)
            }
            completion(entries.flatMap {
                guard let date = $0["last_collected_at"] as? String,
                    lastCollectedAt = Trakt.datetimeFormatter.dateFromString(date),
                    show = TraktShow(data: $0["show"] as? JSONHash) else {
                        return nil
                }
                return (lastCollectedAt: lastCollectedAt, show: show, seasons: ($0["seasons"] as? [JSONHash])?.flatMap {
                    guard let season = TraktSeason(data: $0),
                        episodesData = $0["episodes"] as? [JSONHash]
                        else {
                            return nil
                    }
                    return (season: season, episodes: episodesData.flatMap({
                        guard let episode = TraktEpisode(data: $0),
                            date = $0["collected_at"] as? String,
                            collectedAt = Trakt.datetimeFormatter.dateFromString(date) else {
                                return nil
                        }
                        return (episode: episode, collectedAt: collectedAt)
                    }))
                })
            }, nil)
        }
    }
}
