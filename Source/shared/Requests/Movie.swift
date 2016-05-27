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
    public init(id: AnyObject, extended: TraktRequestExtendedOptions = .Min) {
        super.init(method: "GET", path: "/movies/\(id)", params: ["extended": extended.paramValue()])
    }

    public func request(trakt: Trakt, completion: (TraktMovie?, NSError?) -> Void) -> Request? {
        return trakt.request(self) { response in
            completion(TraktMovie(data: response.result.value as? JSONHash), response.result.error)
        }
    }
}
