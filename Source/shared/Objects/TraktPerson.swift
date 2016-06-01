//
//  TraktPerson.swift
//  Arsonik
//
//  Created by Florian Morello on 04/10/15.
//  Copyright © 2015 Florian Morello. All rights reserved.
//

import Foundation

/// Represents a person
public class TraktPerson: TraktObject {
    /// Person's name
    public let name: String
    /// Person's biography
    public var biography: String?
    /// Person's birthday
    public var birthday: NSDate?
    /// Person's death
    public var death: NSDate?

    /// - seealso: TraktObject.init?(data: JSONHash!)
    required public init?(data: JSONHash!) {
        guard let n = data["name"] as? String else {
            return nil
        }
        name = n

        super.init(data: data)
    }

    /// - seealso: digest(data: JSONHash!)
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

    /**
     Get the age of a person
     - returns: Age
     */
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
