//
//  TraktPerson.swift
//  Arsonik
//
//  Created by Florian Morello on 04/10/15.
//  Copyright © 2015 Florian Morello. All rights reserved.
//

import Foundation

public class TraktPerson: TraktObject {
    public let name: String!
    public let biography: String!
    public let birthday: NSDate!
    public let death: NSDate!

    override init?(data: [String: AnyObject]!) {
        if let n = data["name"] as? String {
            name = n
            biography = data["biography"] as? String

            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy'-'MM'-'dd"

            if let value = data["birthday"] as? String, date = dateFormatter.dateFromString(value) {
                birthday = date
            } else {
                birthday = nil
            }

            if let value = data["death"] as? String, date = dateFormatter.dateFromString(value) {
                death = date
            } else {
                death = nil
            }

            super.init(data: data)
        }
        else {
            name = nil
            biography = nil
            birthday = nil
            death = nil
            super.init(data: data)
            return nil
        }
    }

    public func age() -> Int? {
        if birthday != nil {
            let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
            let ageComponents = calendar.components(.Year,
                fromDate: birthday,
                toDate: death ?? NSDate(),
                options: [])
            return ageComponents.year
        }
        return nil

    }
}

