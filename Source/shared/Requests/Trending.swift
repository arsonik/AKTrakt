//
//  Trending.swift
//  Pods
//
//  Created by Florian Morello on 27/05/16.
//
//

import Foundation
import Alamofire

public class TraktRequestTrending: TraktRequest, TraktRequest_Completion {
    var type: TraktMediaType

    public init(type: TraktMediaType, extended: TraktRequestExtendedOptions = .Min, pagination: TraktPagination = TraktPagination(page: 1, limit: 100)) {
        self.type = type
        var params: JSONHash = [:]
        params += extended.value()
        params += pagination.value()
        super.init(path: "/\(type.rawValue)/trending", params: params)
    }

    public func request(trakt: Trakt, completion: ([(watchers: Int, media: TraktObject)]?, NSError?) -> Void) -> Request? {
        return trakt.request(self) { response in
            guard let entries = response.result.value as? [JSONHash] else {
                return completion(nil, response.result.error)
            }

            let list: [(watchers: Int, media: TraktObject)] = entries.flatMap {
                guard let watchers = $0["watchers"] as? Int,
                    media = self.type == .Movies ? TraktMovie(data: $0["movie"] as? JSONHash) : TraktShow(data: $0["show"] as? JSONHash) as? TraktObject else {
                    return nil
                }
                return (watchers: watchers, media: media)
            }
            completion(list, response.result.error)
        }
    }
}
