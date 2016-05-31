//
//  MovieViewController.swift
//  AKTrakt
//
//  Created by Florian Morello on 24/05/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import AKTrakt
import AlamofireImage

class MovieViewController: UIViewController {

    var movie: TraktMovie!

    lazy var trakt: Trakt = {
        return Trakt.autoload()
    } ()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = movie.title

        loadCasting()
    }

    func loadCasting() {
        TraktRequestMediaPeople(type: .Movies, id: movie.id).request(trakt) { casting, crew, error in
                print(casting)
            }
    }
}
