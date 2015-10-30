//
//  TraktCrew.swift
//  AKTrakt
//
//  Created by Florian Morello on 30/10/15.
//  Copyright © 2015 Florian Morello. All rights reserved.
//

import Foundation

public class TraktCrew {
    let job:String!
    let person:TraktPerson!

    init?(data: [String : AnyObject]!) {
        if let n = data["job"] as? String, p = data["person"] as? [String:AnyObject], pers = TraktPerson(data: p) {
            job = n
            person = pers
        }
        else {
            job = nil
            person = nil
            return nil
        }
    }
}