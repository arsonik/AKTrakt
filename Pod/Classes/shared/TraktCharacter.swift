//
//  TraktCharacter.swift
//  AKTrakt
//
//  Created by Florian Morello on 30/10/15.
//  Copyright © 2015 Florian Morello. All rights reserved.
//

import Foundation

public class TraktCharacter {
    public let character: String!
    public let person: TraktPerson!

    init?(data: [String : AnyObject]!) {
        if let n = data["character"] as? String, p = data["person"] as? [String: AnyObject], pers = TraktPerson(data: p) {
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
