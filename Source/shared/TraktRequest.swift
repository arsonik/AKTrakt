//
//  TraktRequest.swift
//  Pods
//
//  Created by Florian Morello on 25/05/16.
//
//

import Foundation
import Alamofire

// Define a protocol request used by the api
public class TraktRequest {
    public let method: String
    public let path: String
    public let params: JSONHash?

    public var attemptLeft: Int = 5

    init(method: String = "GET", path: String, params: JSONHash? = nil) {
        self.method = method
        self.path = path
        self.params = params
    }
}

// Define a request that handle a completion closure
public protocol TraktRequest_Completion {
    typealias T
    func request(trakt: Trakt, completion: T) -> Request?
}

// Define a request that should not be retried on failure
public protocol TraktRequest_RequireToken {}

public struct TraktRequestExtendedOptions: OptionSetType {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let Min = TraktRequestExtendedOptions(rawValue: 0)
    public static let Images = TraktRequestExtendedOptions(rawValue: 1 << 0)
    public static let Full = TraktRequestExtendedOptions(rawValue: 1 << 1)
    public static let Metadata = TraktRequestExtendedOptions(rawValue: 1 << 2)
    public static let NoSeasons = TraktRequestExtendedOptions(rawValue: 1 << 3)

    public func paramValue() -> String {
        var list: [String] = []
        if contains(.Full) {
            list.append("full")
        }
        if contains(.Images) {
            list.append("images")
        }
        if contains(.Metadata) {
            list.append("metadata")
        }
        if contains(.NoSeasons) {
            list.append("noseasons")
        }
        return list.joinWithSeparator(",")
    }
}

extension Trakt {
    public func request(request: TraktRequest, completionHandler: Response<AnyObject, NSError> -> Void) -> Request? {
        guard let url = NSURL(string: "https://api-v2launch.trakt.tv\(request.path)") else {
            fatalError("Url error ? \(request)")
        }
        let mRequest = NSMutableURLRequest(URL: url)
        mRequest.HTTPMethod = request.method

        mRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        mRequest.setValue("\(traktApiVersion)", forHTTPHeaderField: "trakt-api-version")
        mRequest.setValue(clientId, forHTTPHeaderField: "trakt-api-key")

        if request is TraktRequest_RequireToken {
            if let accessToken = token?.accessToken {
                mRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            } else {
                print("You need an access token that call that resource")
                return nil
            }
        }

        let pRequest = (mRequest.HTTPMethod == "POST" ? ParameterEncoding.JSON : ParameterEncoding.URL).encode(mRequest, parameters: request.params).0

        request.attemptLeft -= 1
        return manager.request(pRequest).responseJSON { [weak self] response in
            guard let ss = self else {
                completionHandler(response)
                return
            }

            if response.response?.statusCode >= 500 {
                if request.attemptLeft > 0 {
                    // try again after delay
                    return delay(ss.retryInterval) {
                        ss.request(request, completionHandler: completionHandler)
                    }
                } else {
                    print("Maximum attempt reached for request \(request)")
                }
            }
            completionHandler(response)
        }
    }
}
