//
//  TraktRelease.swift
//  Pods
//
//  Created by Florian Morello on 29/03/16.
//
//

import Foundation

public class TraktRelease: CustomStringConvertible {

	public let countryCode: String

	public let certification: String

	public let date: NSDate

	public let type: TraktReleaseType

	public let note: String!

	public init?(data: JSONHash?) {
		guard
			let country = data?["country"] as? String,
			certification = data?["certification"] as? String,
			release_date = data?["release_date"] as? String, date = Trakt.dateFormatter.dateFromString(release_date),
			release_type = data?["release_type"] as? String, type = TraktReleaseType(rawValue: release_type)
			else {
			return nil
		}

		self.countryCode = country
		self.certification = certification
		self.date = date
		self.type = type
		self.note = data?["note"] as? String
	}

	public var description: String {
		return "TraktRelease \(countryCode) \(type.rawValue) \(date) \(note) \(certification)"
	}
}


public enum TraktReleaseType: String {
	case Unknown = "unknown"
	case Premiere = "premiere"
	case Limited = "limited"
	case Theatrical = "theatrical"
	case Digital = "digital"
	case Physical = "physical"
	case Tv = "tv"
}
