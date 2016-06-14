//
//  Episode.swift
//  Pods
//
//  Created by Florian Morello on 27/05/16.
//
//

import Foundation
import Alamofire

public class TraktRequestEpisode: TraktRequest {
    public init(showId: AnyObject, season: TraktSeasonNumber, episode: TraktEpisodeNumber, extended: TraktRequestExtendedOptions? = nil) {
        super.init(path: "/shows/\(showId)/seasons/\(season)/episodes/\(episode)", params: extended?.value())
    }

    public func request(_ trakt: Trakt, completion: (TraktEpisode?, NSError?) -> Void) -> Request? {
        return trakt.request(self) { response in
            completion(TraktEpisode(data: response.result.value as? JSONHash), response.result.error)
        }
    }
}
