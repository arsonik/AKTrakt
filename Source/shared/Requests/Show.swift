//
//  Show.swift
//  Pods
//
//  Created by Florian Morello on 25/05/16.
//
//

import Foundation
import Alamofire

public class TraktRequestShow: TraktRequest, TraktRequest_Completion {
    public var extended: TraktRequestExtendedOptions?

    public init(id: AnyObject, extended: TraktRequestExtendedOptions = .Min) {
        super.init(path: "/shows/\(id)", params: ["extended": extended.paramValue()])
        self.extended = extended
    }

    public func request(trakt: Trakt, completion: (TraktShow?, NSError?) -> Void) -> Request? {
        return trakt.request(self) { [weak self] response in
            guard let item = response.result.value as? JSONHash, o = TraktShow(data: item) else {
                return completion(nil, response.result.error)
            }
            completion(o, nil)
        }
    }
}
