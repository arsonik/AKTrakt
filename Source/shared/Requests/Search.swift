//
//  Search.swift
//  Pods
//
//  Created by Florian Morello on 27/05/16.
//
//

import Foundation
import Alamofire

public enum TraktRequestSearchType: String {
    case Movie = "movie"
    case Show = "show"
    case Episode = "episode"
    case Person = "person"
    // case List = "list" // Todo

    var classType: TraktObject.Type? {
        switch self {
        case .Movie:
            return TraktMovie.self
        case .Show:
            return TraktShow.self
        case .Person:
            return TraktPerson.self
        case .Episode:
            return TraktEpisode.self
        }
    }
}

public class TraktRequestSearch: TraktRequest, TraktRequest_Completion {
    public init(query: String, type: TraktRequestSearchType? = nil, year: UInt? = nil, pagination: TraktPagination? = nil) {
        var params: JSONHash = [
            "query": query
        ]
        if year != nil {
            params["year"] = year!
        }
        if type != nil {
            params["type"] = type!.rawValue
        }
        if pagination != nil {
            params += pagination!.value()
        }
        super.init(path: "/search", params: params)
    }

    public func request(trakt: Trakt, completion: ([TraktObject]?, NSError?) -> Void) throws -> Request? {
        return try trakt.request(self) { response in
            guard let entries = response.result.value as? [JSONHash] else {
                return completion(nil, response.result.error)
            }

            completion(entries.flatMap {
                guard let type = TraktRequestSearchType(rawValue: $0["type"] as? String ?? "") else {
                    return nil
                }
                return type.classType?.init(data: $0[type.rawValue] as? JSONHash)
            }, nil)
        }
    }
}
