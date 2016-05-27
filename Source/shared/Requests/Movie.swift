//
//  Movie.swift
//  Pods
//
//  Created by Florian Morello on 26/05/16.
//
//

import Foundation
import Alamofire

public class TraktRequestMovie: TraktRequest, TraktRequest_Completion {
    public init(id: AnyObject, extended: TraktRequestExtendedOptions? = nil) {
        super.init(path: "/movies/\(id)", params: extended?.value())
    }

    public func request(trakt: Trakt, completion: (TraktMovie?, NSError?) -> Void) throws -> Request? {
        return try trakt.request(self) { response in
            completion(TraktMovie(data: response.result.value as? JSONHash), response.result.error)
        }
    }
}


public class TraktRequestMovieReleases: TraktRequest, TraktRequest_Completion {
    public init(id: AnyObject, country: String? = nil, extended: TraktRequestExtendedOptions? = nil) {
        super.init(path: "/movies/\(id)/releases" + (country != nil ? "/\(country!)" : ""), params: extended?.value())
    }

    public func request(trakt: Trakt, completion: ([TraktRelease]?, NSError?) -> Void) throws -> Request? {
        return try trakt.request(self) { response in
            guard let data = response.result.value as? [JSONHash] else {
                return completion(nil, response.result.error)
            }
            completion(data.flatMap { TraktRelease(data: $0) }, response.result.error)
        }
    }
}
