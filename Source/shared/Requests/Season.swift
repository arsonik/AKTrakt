//
//  Season.swift
//  Pods
//
//  Created by Florian Morello on 27/05/16.
//
//

import Foundation
import Alamofire

public class TraktRequestSeason: TraktRequest {
    public init(showId: AnyObject, seasonNumber: UInt, extended: TraktRequestExtendedOptions? = nil) {
        super.init(path: "/shows/\(showId)/seasons/\(seasonNumber)", params: extended?.value())
    }

    public func request(_ trakt: Trakt, completion: ([TraktEpisode]?, NSError?) -> Void) -> Request? {
        return trakt.request(self) { response in
            guard let items = response.result.value as? [JSONHash] else {
                return completion(nil, response.result.error)
            }
            completion(items.flatMap {
                TraktEpisode(data: $0)
            }, nil)
        }
    }
}

public class TraktRequestSeasons: TraktRequest {
    public init(showId: AnyObject, extended: TraktRequestExtendedOptions? = nil) {
        super.init(path: "/shows/\(showId)/seasons/", params: extended?.value())
    }

    public func request(_ trakt: Trakt, completion: ([TraktSeason]?, NSError?) -> Void) -> Request? {
        return trakt.request(self) { response in
            guard let items = response.result.value as? [JSONHash] else {
                return completion(nil, response.result.error)
            }
            completion(items.flatMap {
                TraktSeason(data: $0)
            }.sorted {
                $0.number < $1.number
            }, nil)
        }
    }
}
