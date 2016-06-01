//
//  Show.swift
//  Pods
//
//  Created by Florian Morello on 25/05/16.
//
//

import Foundation
import Alamofire

public class TraktRequestShow: TraktRequest, TraktRequest_Completion {
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

public class TraktRequestShowProgress: TraktRequest, TraktRequest_Completion {
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

    public func request(trakt: Trakt, completion: ([TraktSeason]?, NSError?) -> Void) -> Request? {
        return trakt.request(self) { response in
            guard let data = response.result.value as? JSONHash,
//                nextEpisode = data["next_episode"] as? JSONHash,
                seasons = data["seasons"] as? [JSONHash] else {
                return completion(nil, response.result.error)
            }
            // TraktEpisode(data: nextEpisode),
            completion(seasons.flatMap {
                TraktSeason(data: $0)
            }, nil)
        }
    }
}
