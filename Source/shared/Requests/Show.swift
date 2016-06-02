//
//  Show.swift
//  Pods
//
//  Created by Florian Morello on 25/05/16.
//
//

import Foundation
import Alamofire

public class TraktRequestShow: TraktRequest {
    public init(id: AnyObject, extended: TraktRequestExtendedOptions? = nil) {
        super.init(path: "/shows/\(id)", params: extended?.value())
    }

    public func request(trakt: Trakt, completion: (TraktShow?, NSError?) -> Void) -> Request? {
        return trakt.request(self) { response in
            guard let item = response.result.value as? JSONHash, o = TraktShow(data: item) else {
                return completion(nil, response.result.error)
            }
            completion(o, nil)
        }
    }
}

public class TraktRequestShowProgress: TraktRequest {
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
     - parameter completion: closure return the next episode to watch and all the seasons/episodes, NSError

     - returns: Alamofire.Request
     */
    public func request(trakt: Trakt, completion: (TraktEpisode?, [TraktSeason]?, NSError?) -> Void) -> Request? {
        return trakt.request(self) { response in
            guard let data = response.result.value as? JSONHash,
                nextEpisode = TraktEpisode(data: data["next_episode"] as? JSONHash),
                seasons = data["seasons"] as? [JSONHash] else {
                return completion(nil, nil, response.result.error)
            }
            completion(nextEpisode, seasons.flatMap {
                TraktSeason(data: $0)
            }, nil)
        }
    }
}
