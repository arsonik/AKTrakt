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

        if let image = view.viewWithTag(1) as? UIImageView, url = movie.imageURL(.FanArt, thatFits: image) {
            image.af_setImageWithURL(url, placeholderImage: nil)
        }

        loadCasting()
    }

    func loadCasting() {
        TraktRequestMediaPeople(type: TraktMovie.self, id: movie.id).request(trakt) { casting, crew, error in
            print(casting)
        }
    }
}
