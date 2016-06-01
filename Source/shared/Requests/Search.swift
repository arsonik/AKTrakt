//
//  Search.swift
//  Pods
//
//  Created by Florian Morello on 27/05/16.
//
//

import Foundation
import Alamofire

public class TraktRequestSearch: TraktRequest {
    public init(query: String, type: TraktType? = nil, year: UInt? = nil, pagination: TraktPagination? = nil) {
        var params: JSONHash = [
            "query": query
        ]
        if year != nil {
            params["year"] = year!
        }
        if type != nil {
            params["type"] = type!.single
        }
        if pagination != nil {
            params += pagination!.value()
        }
        super.init(path: "/search", params: params)
    }

    public func request(trakt: Trakt, completion: ([TraktObject]?, NSError?) -> Void) -> Request? {
        return trakt.request(self) { response in
            guard let entries = response.result.value as? [JSONHash] else {
                return completion(nil, response.result.error)
            }

            completion(entries.flatMap {
                guard let type = TraktType(rawValue: $0["type"] as? String ?? "") else {
                    return nil
                }
                return type.classType?.init(data: $0[type.rawValue] as? JSONHash)
            }, nil)
        }
    }
}
