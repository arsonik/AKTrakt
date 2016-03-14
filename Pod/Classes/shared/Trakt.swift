//
//  Trakt.swift
//  Arsonik
//
//  Created by Florian Morello on 08/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation
import Alamofire

/// Main Class
public class Trakt {
	internal let clientId: String
    internal let clientSecret: String
    internal let applicationId: Int
    private var token: TraktToken?
	internal var retryInterval: Double = 5
	private var attempts = NSCache()
	internal var maximumAttempt: Int = 5
    private let manager: Manager

	public typealias GeneratedCodeResponse = (deviceCode: String, userCode: String, verificationUrl: String, expiresAt: NSDate, interval: NSTimeInterval)
	public typealias JSONHash = [String: AnyObject!]

    public init(clientId: String, clientSecret: String, applicationId: Int) {
		self.clientId = clientId
		self.clientSecret = clientSecret
        self.applicationId = applicationId

        manager = Manager()

        // autoload token
        if let storedToken = TraktToken.load(clientId) {
            token = storedToken
        }
	}

	public func hasValidToken() -> Bool {
		return token != nil
	}
	
	public func clearToken() {
		token?.remove(clientId)
		token = nil
	}

	public func saveToken(token: TraktToken) {
		token.save(clientId)
		self.token = token
	}

	internal lazy var dateFormatter: NSDateFormatter = {
		let df = NSDateFormatter()
		df.locale = NSLocale(localeIdentifier: "en_US_POSIX")
		df.timeZone = NSTimeZone(forSecondsFromGMT: 0)
		df.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.000Z'"
		return df
	}()

	internal func query(route: TraktRoute, completionHandler: Response<AnyObject, NSError> -> Void) -> Request! {
		let request = route.URLRequest
		request.setValue("2", forHTTPHeaderField: "trakt-api-version")
		request.setValue(clientId, forHTTPHeaderField: "trakt-api-key")

		if route.needAuthorization() {
			if let accessToken = token?.accessToken {
				request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
			} else {
				print("You need an access token that call that resource")
				return nil
			}
		}

		let key = "\(route.hashValue)"
		return manager.request(request).responseJSON { [weak self] response in
			if let interval = self?.retryInterval where response.response?.statusCode >= 500 && route.retryOnFailure() {
				var attempt: Int = self?.attempts.objectForKey(key) as? Int ?? 1
				self?.attempts.setValue(++attempt, forKey: key)
				if attempt < self!.maximumAttempt {
					return delay(interval) {
						self?.query(route, completionHandler: completionHandler)
					}
				} else {
					print("Maximum attempt reached for request \(route)")
				}
			}
			self?.attempts.removeObjectForKey(key)
			completionHandler(response)
		}
	}
}
