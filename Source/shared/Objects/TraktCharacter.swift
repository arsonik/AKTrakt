//
//  TraktCharacter.swift
//  AKTrakt
//
//  Created by Florian Morello on 30/10/15.
//  Copyright © 2015 Florian Morello. All rights reserved.
//

import Foundation

/// Represents a character with the person related to it
public struct TraktCharacter {
    /// Character's name
    public let character: String

    /// Person's object
    public let person: TraktPerson

    /*
    Init with data
    - parameter data: JSONHash
    */
    init?(data: JSONHash) {
        guard let n = data["character"] as? String, let p = data["person"] as? JSONHash, let pers = TraktPerson(data: p) else {
            return nil
        }
        character = n
        person = pers
    }
}
