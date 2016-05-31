//
//  TraktPerson.swift
//  Arsonik
//
//  Created by Florian Morello on 04/10/15.
//  Copyright © 2015 Florian Morello. All rights reserved.
//

import Foundation

public class TraktPerson: TraktObject {
    public let name: String
    public var biography: String?
    public var birthday: NSDate?
    public var death: NSDate?

    required public init?(data: JSONHash!) {
        guard let n = data["name"] as? String else {
            return nil
        }
        name = n

        super.init(data: data)
    }

    public override func digest(data: JSONHash?) {
        super.digest(data)

        biography = data?["biography"] as? String

        if let value = data?["birthday"] as? String, date = Trakt.dateFormatter.dateFromString(value) {
            birthday = date
        }

        if let value = data?["death"] as? String, date = Trakt.dateFormatter.dateFromString(value) {
            death = date
        }
    }

    public func age() -> Int? {
        guard birthday != nil else {
            return nil
        }
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let ageComponents = calendar.components(.Year,
                                                fromDate: birthday!,
                                                toDate: death ?? NSDate(),
                                                options: [])
        return ageComponents.year
    }
}
