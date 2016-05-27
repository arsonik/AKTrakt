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
    public let tokenRequired: Bool
    public let headers: [String: String]?

    public var attemptLeft: Int = 5

    public init(method: String = "GET", path: String, params: JSONHash? = nil, tokenRequired: Bool = false, headers: [String: String]? = [:]) {
        self.method = method
        self.path = path
        self.params = params
        self.tokenRequired = tokenRequired
        self.headers = headers
    }
}

// Define a request that handle a completion closure
public protocol TraktRequest_Completion {
    typealias T
    func request(trakt: Trakt, completion: T) throws -> Request?
}

public protocol TraktURLParameters {
    func value() -> JSONHash
}

public protocol TraktRequestHeaders {
    func value() -> [String: String]
}

public struct TraktSortHeaders: TraktRequestHeaders {
    public let sortBy: String = "rank"
    public let sortHow: String = "asc"

    public func value() -> [String : String] {
        return [
            "X-Sort-By": sortBy,
            "X-Sort-How": sortHow
        ]
    }
}

public struct TraktPagination: TraktURLParameters {
    var page: Int = 1
    var limit: Int = 10

    public init(page: Int, limit: Int) {
        self.page = page
        self.limit = limit
    }

    public func value() -> JSONHash {
        return [
            "page": page,
            "limit": limit
        ]
    }
}

public struct TraktRequestExtendedOptions: OptionSetType, TraktURLParameters {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let Min = TraktRequestExtendedOptions(rawValue: 0)
    public static let Images = TraktRequestExtendedOptions(rawValue: 1 << 0)
    public static let Full = TraktRequestExtendedOptions(rawValue: 1 << 1)
    public static let Metadata = TraktRequestExtendedOptions(rawValue: 1 << 2)
    public static let NoSeasons = TraktRequestExtendedOptions(rawValue: 1 << 3)

    public func value() -> JSONHash {
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
        return ["extended": list.joinWithSeparator(",")]
    }
}

public enum TraktError: ErrorType {
    case TokenRequired
}

extension Trakt {
    public func request(request: TraktRequest, completionHandler: Response<AnyObject, NSError> -> Void) throws -> Request? {
        guard let url = NSURL(string: "https://api-v2launch.trakt.tv\(request.path)") else {
            fatalError("Url error ? \(request)")
        }
        let mRequest = NSMutableURLRequest(URL: url)
        mRequest.HTTPMethod = request.method

        mRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        mRequest.setValue("\(traktApiVersion)", forHTTPHeaderField: "trakt-api-version")
        mRequest.setValue(clientId, forHTTPHeaderField: "trakt-api-key")

        if request.tokenRequired {
            if let accessToken = token?.accessToken {
                mRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            } else {
                throw TraktError.TokenRequired
            }
        }

        request.headers?.forEach {
            mRequest.setValue($0.1, forHTTPHeaderField: $0.0)
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
                        try! ss.request(request, completionHandler: completionHandler) // swiftlint:disable:this force_try
                        return
                    }
                } else {
                    print("Maximum attempt reached for request \(request)")
                }
            }
            completionHandler(response)
        }
    }
}
