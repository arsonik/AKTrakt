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
public protocol TraktRequest {
    var path: String { get }
    var params: JSONHash? { get }
}

// Define a GET request
public protocol TraktRequestGET: TraktRequest {}

// Define a POST request
public protocol TraktRequestPOST: TraktRequest {}

// Define a DELETE request
public protocol TraktRequestDELETE: TraktRequest {}

// Define a request that need a logged user
public protocol TraktRequestLogged {}

// Define a request that should not be retried on failure
public protocol TraktRequestOnlyOnce {}

// Define a request that can have extended arguments like (full, images)
public protocol TraktRequestExtended {
    var extended: TraktRequestExtendedOptions? { get }
}

public struct TraktRequestExtendedOptions: OptionSetType {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let None = TraktRequestExtendedOptions(rawValue: 0)
    public static let Images = TraktRequestExtendedOptions(rawValue: 1 << 0)
    public static let Full = TraktRequestExtendedOptions(rawValue: 1 << 1)
    public static let Metadata = TraktRequestExtendedOptions(rawValue: 1 << 2)
}


extension Trakt {
    public func request(request: TraktRequest, completionHandler: Response<AnyObject, NSError> -> Void) -> Request? {
        guard let url = NSURL(string: "https://api-v2launch.trakt.tv\(request.path)") else {
            fatalError("Url error ? \(request)")
        }
        let mRequest = NSMutableURLRequest(URL: url)
        if request is TraktRequestGET {
            mRequest.HTTPMethod = "GET"
        } else if request is TraktRequestDELETE {
            mRequest.HTTPMethod = "DELETE"
        } else if request is TraktRequestPOST {
            mRequest.HTTPMethod = "POST"
        }
        mRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        mRequest.setValue("\(traktApiVersion)", forHTTPHeaderField: "trakt-api-version")
        mRequest.setValue(clientId, forHTTPHeaderField: "trakt-api-key")

        var params = request.params

        if request is TraktRequestLogged {
            if let accessToken = token?.accessToken {
                mRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            } else {
                print("You need an access token that call that resource")
                return nil
            }
        }

        if let ext = (request as? TraktRequestExtended)?.extended {
            if params == nil {
                params = [:]
            }
            var list: [String] = []
            if ext.contains(.Full) {
                list.append("full")
            }
            if ext.contains(.Images) {
                list.append("images")
            }
            params!["extended"] = list.joinWithSeparator(",")
        }

        let pRequest = (mRequest.HTTPMethod == "POST" ? ParameterEncoding.JSON : ParameterEncoding.URL).encode(mRequest, parameters: params).0

        let key = pRequest.hashDescription()
        return manager.request(pRequest).responseJSON { [weak self] response in
            guard let ss = self else {
                completionHandler(response)
                return
            }

            if response.response?.statusCode >= 500 && !(request is TraktRequestOnlyOnce) {
                var attempt: Int = ss.attempts.objectForKey(key) as? Int ?? 0
                attempt += 1
                ss.attempts.setObject(attempt, forKey: key)
                if attempt < ss.maximumAttempt {
                    // try again after delay
                    return delay(ss.retryInterval) {
                        ss.request(request, completionHandler: completionHandler)
                    }
                } else {
                    print("Maximum attempt \(attempt)/\(ss.maximumAttempt) reached for request \(request)")
                }
            }
            ss.attempts.removeObjectForKey(key)

            completionHandler(response)
        }
    }
}