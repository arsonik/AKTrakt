//
//  Recommendations.swift
//  Pods
//
//  Created by Florian Morello on 27/05/16.
//
//

import Foundation
import Alamofire

public class TraktRequestRecommendations: TraktRequest, TraktRequest_Completion {
    var type: TraktType

    public init(type: TraktType, extended: TraktRequestExtendedOptions = .Min, pagination: TraktPagination = TraktPagination(page: 1, limit: 100)) {
        self.type = type
        var params: JSONHash = [:]
        params += extended.value()
        params += pagination.value()
        super.init(path: "/recommendations/\(type.rawValue)", params: params, oAuth: true)
    }

    public func request(trakt: Trakt, completion: ([TraktObject]?, NSError?) -> Void) -> Request? {
        return trakt.request(self) { response in
            guard let entries = response.result.value as? [JSONHash] else {
                return completion(nil, response.result.error)
            }
            let list: [TraktObject] = entries.flatMap {
                if self.type == TraktType.Shows {
                    return TraktShow(data: $0)
                } else {
                    return TraktMovie(data: $0)
                }
            }
            completion(list, response.result.error)
        }
    }
}

public class TraktRequestRecommendationsHide: TraktRequest, TraktRequest_Completion {
    public init(type: TraktType, id: AnyObject) {
        super.init(method: "DELETE", path: "/recommendations/\(type.rawValue)/\(id)", oAuth: true)
    }

    public func request(trakt: Trakt, completion: (Bool?, NSError?) -> Void) -> Request? {
        return trakt.request(self) { response in
            completion(response.response?.statusCode == 204, response.result.error)
        }
    }
}
