//
//  Authentication.swift
//  Pods
//
//  Created by Florian Morello on 25/05/16.
//
//

import Foundation
import Alamofire

///	Generate new device codes
public struct TraktRequestGenerateCode: TraktRequestPOST {
    public var path: String = "/oauth/device/code"
    public var params: JSONHash? = nil

    init(clientId: String) {
        params = ["client_id": clientId]
    }
}

///	Poll for the access_token
public struct TraktRequestPollDevice: TraktRequestPOST, TraktRequestOnlyOnce {
    public var path: String = "/oauth/device/token"
    public var params: JSONHash? = nil

    init(deviceCode: String, clientId: String, clientSecret: String) {
        params = [
            "client_id": clientId,
            "client_secret": clientSecret,
            "code": deviceCode,
        ]
    }
}

///	Exchange code for access_token
public struct TraktRequestToken: TraktRequestPOST {
    public var path: String = "/oauth/token"
    public var params: JSONHash? = nil

    init(trakt: Trakt, pin: String) {
        params = [
            "code": pin,
            "client_id": trakt.clientId,
            "client_secret": trakt.clientSecret,
            "redirect_uri": "urn:ietf:wg:oauth:2.0:oob",
            "grant_type": "authorization_code"
        ]
    }
}

extension Trakt {
    internal func exchangePinForToken(pin: String, completion: (TraktToken?, NSError?) -> Void) -> Request? {
        return request(TraktRequestToken(trakt: self, pin: pin)) { response in
            guard let aToken = TraktToken(data: response.result.value as? JSONHash) else {
                let err: NSError?
                if let error = (response.result.value as? JSONHash)?["error_description"] as? String {
                    err = NSError(domain: "trakt.tv", code: 401, userInfo: [NSLocalizedDescriptionKey: error])
                } else {
                    err = response.result.error
                }
                return completion(nil, err)
            }

            completion(aToken, nil)
        }
    }

    public func generateCode(completion: (GeneratedCodeResponse?, NSError?) -> Void) -> Request? {
        return request(TraktRequestGenerateCode(clientId: clientId)) { response in
            guard
                let data = response.result.value as? JSONHash,
                deviceCode = data["device_code"] as? String,
                userCode = data["user_code"] as? String,
                verificationUrl = data["verification_url"] as? String,
                expiresIn = data["expires_in"] as? Double,
                interval = data["interval"] as? Double else {
                    return completion(nil, response.result.error)
            }
            completion((deviceCode: deviceCode, userCode: userCode, verificationUrl: verificationUrl, expiresAt: NSDate().dateByAddingTimeInterval(expiresIn), interval: interval), nil)
        }
    }

    public func pollDevice(response: GeneratedCodeResponse, completion: (TraktToken?, NSError?) -> Void) -> Request? {
        return request(TraktRequestPollDevice(deviceCode: response.deviceCode, clientId: clientId, clientSecret: clientSecret)) { response in
            completion(TraktToken(data: response.result.value as? JSONHash), response.result.error)
        }
    }
}
