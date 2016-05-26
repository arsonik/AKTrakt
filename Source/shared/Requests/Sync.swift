//
//  Sync.swift
//  Pods
//
//  Created by Florian Morello on 26/05/16.
//
//

import Foundation
import Alamofire

/**
 Returns all movies or shows a user has watched sorted by most plays.
 If type is set to shows and you add ?extended=noseasons to the URL, it won't return season or episode info.
 */
public typealias TraktRequestWatchedCompletion = ([TraktObject]?, NSError?) -> Void

public struct TraktRequestWatched: TraktRequestGET, TraktRequestExtended {
    public var path: String
    public var params: JSONHash?
    public var extended: TraktRequestExtendedOptions?

    public var completion: TraktRequestWatchedCompletion!

    public init(type: TraktMediaType, extended: TraktRequestExtendedOptions? = nil, completion: TraktRequestWatchedCompletion) {
        path = "/movies/trending"
        self.extended = extended

        self.completion = completion
    }

    public func request(trakt: Trakt) {
        trakt.request(self) { response in
            guard let entries = response.result.value as? [JSONHash] else {
                return self.completion(nil, response.result.error)
            }

            let list: [TraktWatchable] = entries.flatMap {
                return TraktMovie(data: $0["movie"] as? JSONHash)
            }
            self.completion?(list, response.result.error)
        }
    }
}