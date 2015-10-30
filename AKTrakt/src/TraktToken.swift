//
//  TraktToken.swift
//  Arsonik
//
//  Created by Florian Morello on 10/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import Foundation

class TraktToken : CustomStringConvertible {
	let accessToken:String!
	let expire:NSDate!
	let refreshToken:String!
	
	init(accessToken:String, expire:NSDate, refreshToken:String){
		self.accessToken = accessToken
		self.expire = expire
		self.refreshToken = refreshToken
	}
	
	init?(data:[String:AnyObject]!){
		if let token = data, access_token = token["access_token"] as? String, expiresin = token["expires_in"] as? Int, rt = token["refresh_token"] as? String {
			self.expire = NSDate(timeIntervalSinceNow: Double(expiresin))
			self.accessToken = access_token
			self.refreshToken = rt
		}
		else{
			self.accessToken = nil
			self.expire = nil
			self.refreshToken = nil
			return nil
		}
	}
	
	var description:String {
		return "TraktToken(\(accessToken) - \(expire))"
	}
}