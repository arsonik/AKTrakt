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


