//
//  Recommendations.swift
//  Pods
//
//  Created by Florian Morello on 27/05/16.
//
//

import Foundation
import Alamofire

public class TraktRequestRecommendations<T: TraktObject where T: protocol<Recommandable>>: TraktRequest {
    let type: T.Type

    public init(type: T.Type, extended: TraktRequestExtendedOptions? = nil, pagination: TraktPagination? = nil) {
        self.type = type
        var params: JSONHash = [:]
        if extended != nil {
            params += extended!.value()
        }
        if pagination != nil {
            params += pagination!.value()
        }
        super.init(path: "/recommendations/\(type.listName)", params: params, oAuth: true)
    }

    public func request(_ trakt: Trakt, completion: ([T]?, NSError?) -> Void) -> Request? {
        return trakt.request(self) { response in
            guard let entries = response.result.value as? [JSONHash] else {
                return completion(nil, response.result.error)
            }
            completion(entries.flatMap {
                self.type.init(data: $0)
            }, response.result.error)
        }
    }
}

public class TraktRequestRecommendationsHide<T: TraktObject where T: protocol<Recommandable>>: TraktRequest {
    public init(type: T.Type, id: AnyObject) {
        super.init(method: "DELETE", path: "/recommendations/\(type.listName)/\(id)", oAuth: true)
    }

    public func request(_ trakt: Trakt, completion: (Bool?, NSError?) -> Void) -> Request? {
        return trakt.request(self) { response in
            completion(response.response?.statusCode == 204, response.result.error)
        }
    }
}
