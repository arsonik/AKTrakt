//
//  TraktCrew.swift
//  AKTrakt
//
//  Created by Florian Morello on 30/10/15.
//  Copyright © 2015 Florian Morello. All rights reserved.
//

import Foundation

public struct TraktCrew {

    /// Person's job
    public let job: String

    /// Person's object
    public let person: TraktPerson

    init?(data: JSONHash) {
        guard let n = data["job"] as? String, p = data["person"] as? JSONHash, pers = TraktPerson(data: p) else {
            return nil
        }

        job = n
        person = pers
    }
}
