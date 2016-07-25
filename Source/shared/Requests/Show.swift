//
//  Show.swift
//  Pods
//
//  Created by Florian Morello on 25/05/16.
//
//

import Foundation
import Alamofire

/// Request for a show
public class TraktRequestShow: TraktRequest {
    /**
     Init with a show

     - parameter id:       show identifier
     - parameter extended: extended data
     */
    public init(id: AnyObject, extended: TraktRequestExtendedOptions? = nil) {
        super.init(path: "/shows/\(id)", params: extended?.value())
    }

    /**
     Request the show

     - parameter trakt:      trakt client
     - parameter completion: closure TraktShow?, NSError?

     - returns: Alamofire.Request
     */
    public func request(_ trakt: Trakt, completion: (TraktShow?, NSError?) -> Void) -> Request? {
        return trakt.request(self) { response in
            guard let item = response.result.value as? JSONHash, let o = TraktShow(data: item) else {
                return completion(nil, response.result.error)
            }
            completion(o, nil)
        }
    }
}

/// Request for a show progress
public class TraktRequestShowProgress: TraktRequest {
    /**
     Init request with a show id

     - parameter showId:   show identifier
     - parameter extended: extended data
     - parameter hidden:   include hidden seasons
     - parameter specials: include specials seasons
     */
    public init(showId: AnyObject, extended: TraktRequestExtendedOptions? = nil, hidden: Bool = false, specials: Bool = false) {
        var params: JSONHash = [
            "hidden": hidden,
            "specials": specials
        ]
        if extended != nil {
            params += extended!.value()
        }
        super.init(path: "/shows/\(showId)/progress/watched", params: params, oAuth: true)
    }

    /**
     Request show progress

     - parameter trakt:      trakt client
     - parameter completion: closure return the seasons/episodes for the show, NSError

     - returns: Alamofire.Request
     */
    public func request(_ trakt: Trakt, completion: ([TraktSeason]?, NSError?) -> Void) -> Request? {
        return trakt.request(self) { response in
            guard let data = response.result.value as? JSONHash,
                let seasonsData = data["seasons"] as? [JSONHash] else {
                return completion(nil, response.result.error)
            }
            var seasons = seasonsData.flatMap {
                TraktSeason(data: $0)
            }
            // extend next episode
            if let nextEpisode = TraktEpisode(data: data["next_episode"] as? JSONHash),
                nextEpisode.seasonNumber != nil {
                nextEpisode.watched = false
                if let season = seasons.filter({ $0.number == nextEpisode.seasonNumber! }).first {
                    if season.episode(nextEpisode.number) == nil {
                        season.episodes.append(nextEpisode)
                    } else {
                        season.episode(nextEpisode.number)?.extend(nextEpisode)
                    }
                } else {
                    let season = TraktSeason(data: ["number": nextEpisode.seasonNumber!])!
                    season.episodes = [nextEpisode]
                    seasons.append(season)
                }
            }

            completion(seasons, nil)
        }
    }
}
