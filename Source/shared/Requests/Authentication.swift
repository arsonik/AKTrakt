//
//  Authentication.swift
//  Pods
//
//  Created by Florian Morello on 25/05/16.
//
//

import Foundation
import Alamofire

public typealias GeneratedCodeResponse = (deviceCode: String, userCode: String, verificationUrl: String, expiresAt: NSDate, interval: NSTimeInterval)

///	Generate new device codes
public class TraktRequestGenerateCode: TraktRequest, TraktRequest_Completion {
    public init(clientId: String) {
        super.init(method: "POST", path: "/oauth/device/code", params: ["client_id": clientId])
    }

    public func request(trakt: Trakt, completion: (GeneratedCodeResponse?, NSError?) -> Void) -> Request? {
        return trakt.request(self) { response in
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
}

///	Poll for the access_token
public class TraktRequestPollDevice: TraktRequest, TraktRequest_Completion {
    public init(trakt: Trakt, deviceCode: String) {
        super.init(method: "POST", path: "/oauth/device/token", params: [
            "client_id": trakt.clientId,
            "client_secret": trakt.clientSecret,
            "code": deviceCode,
            ])
        attemptLeft = 1
    }

    public func request(trakt: Trakt, completion: (TraktToken?, NSError?) -> Void) -> Request? {
        return trakt.request(self) { response in
            completion(TraktToken(data: response.result.value as? JSONHash), response.result.error)
        }
    }
}

///	Exchange code for access_token
public class TraktRequestToken: TraktRequest, TraktRequest_Completion {
    public init(trakt: Trakt, pin: String) {
        super.init(method: "POST", path: "/oauth/token", params: [
            "code": pin,
            "client_id": trakt.clientId,
            "client_secret": trakt.clientSecret,
            "redirect_uri": "urn:ietf:wg:oauth:2.0:oob",
            "grant_type": "authorization_code"
            ])
    }

    public func request(trakt: Trakt, completion: (TraktToken?, NSError?) -> Void) -> Request? {
        return trakt.request(self) { response in
            completion(TraktToken(data: response.result.value as? JSONHash), response.result.error)
        }
    }
}
