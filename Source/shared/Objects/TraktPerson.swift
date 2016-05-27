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
    public let biography: String?
    public let birthday: NSDate?
    public let death: NSDate?

    required public init?(data: JSONHash!) {

        guard let n = data["name"] as? String else {
            return nil
        }

        name = n
        biography = data["biography"] as? String

        if let value = data["birthday"] as? String, date = Trakt.dateFormatter.dateFromString(value) {
            birthday = date
        } else {
            birthday = nil
        }

        if let value = data["death"] as? String, date = Trakt.dateFormatter.dateFromString(value) {
            death = date
        } else {
            death = nil
        }

        super.init(data: data)
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
