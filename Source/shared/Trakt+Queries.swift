//
//  Trakt+Queries.swift
//  Pods
//
//  Created by Florian Morello on 11/03/16.
//
//

import Foundation
import Alamofire

extension Trakt {
    public func unWatch(object: protocol<TraktIdentifiable, Watchable>, completion: ((Bool, NSError?) -> Void)) -> Request {
        return query(.RemoveFromHistory([object])) { response in
            guard let item = response.result.value as? JSONHash, added = item["deleted"] as? [String: Int], n = added[object.type.rawValue] where n > 0 else {
                return completion(false, response.result.error)
            }
            object.watched = false
            completion(true, nil)
        }
    }

    public func hideFromRecommendations(object: protocol<TraktIdentifiable, Watchable>, completion: ((Bool, NSError?) -> Void)? = nil) -> Request {
        return query(.HideRecommendation(object)) { response in
            completion?((response.response?.statusCode == 204) ?? false, response.result.error)
        }
    }

    public func removeFromWatchlist(object: protocol<TraktIdentifiable, Watchable>, completion: ((Bool, NSError?) -> Void)) -> Request {
        return query(.RemoveFromWatchlist([object])) { response in
            guard let result = response.result.value as? JSONHash,
                added = result["deleted"] as? [String: Int],
                success = added[object.type.rawValue]
                where success == 1 else {
                    return completion(false, response.result.error)
            }
            object.watchlist = false
            completion(true, nil)
        }
    }

    public typealias WatchedReturn = (object: TraktWatchable, plays: Int, lastWatchedAt: NSDate)

    public func episodes(id: AnyObject, seasonNumber: Int, completion: ([TraktEpisode]?, NSError?) -> Void) -> Request {
        return query(.Season(id, seasonNumber)) { response in
            guard let items = response.result.value as? [JSONHash] else {
                return completion(nil, response.result.error)
            }
            completion(items.flatMap { TraktEpisode(data: $0) }, response.result.error)
        }
    }

    public func seasons(id: AnyObject, completion: ([TraktSeason]?, NSError?) -> Void) -> Request {
        return query(.Season(id, nil)) { response in
            guard let items = response.result.value as? [JSONHash] else {
                return completion(nil, response.result.error)
            }
            completion(items.flatMap { TraktSeason(data: $0) }, response.result.error)
        }
    }

    public func progress(show: TraktShow, completion: ((Bool, NSError?) -> Void)) -> Request {
        return query(.Progress(show)) { response in
            guard let data = response.result.value as? JSONHash else {
                return completion(false, response.result.error)
            }

            (data["seasons"] as? [JSONHash])?.forEach { seasonData in
                if let season = TraktSeason(data: seasonData), episodes = seasonData["episodes"] as? [JSONHash] {
                    episodes.flatMap {
                        var test = $0
                        test["season"] = season.number
                        return TraktEpisode(data: test)
                        }.forEach {
                            season.addEpisode($0)
                    }
                    show.addSeason(season)
                }
            }

            if let nxt = data["next_episode"] as? JSONHash, next = TraktEpisode(data: nxt) {
                show.nextEpisode = next
                if show.season(next.seasonNumber!)?.episode(next.number) == nil {
                    if let season = show.season(next.seasonNumber!) {
                        season.addEpisode(next)
                    } else if let season = TraktSeason(data: ["number": next.seasonNumber]) {
                        season.addEpisode(next)
                        show.addSeason(season)
                    }
                }
            }

            return completion(true, response.result.error)
        }
    }
}
