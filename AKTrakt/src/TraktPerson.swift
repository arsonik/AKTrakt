//
//  TraktPerson.swift
//  Arsonik
//
//  Created by Florian Morello on 04/10/15.
//  Copyright © 2015 Florian Morello. All rights reserved.
//

import Foundation

class TraktPerson : TraktObject {

    let name:String!

    override init?(data: [String : AnyObject]!) {

        if let n = data["name"] as? String {
            name = n
            super.init(data: data)
        }
        else {
            name = nil
            super.init(data: data)
            return nil
        }
    }
}

class TraktCharacter {
    let character:String!
    let person:TraktPerson!

    init?(data: [String : AnyObject]!) {
        if let n = data["character"] as? String, p = data["person"] as? [String:AnyObject], pers = TraktPerson(data: p) {
            character = n
            person = pers
        }
        else {
            character = nil
            person = nil
            return nil
        }
    }
}

class TraktCrew {
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