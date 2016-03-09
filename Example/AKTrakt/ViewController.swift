//
//  ViewController.swift
//  AKTrakt
//
//  Created by Florian Morello on 10/30/2015.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import UIKit
import AKTrakt

class ViewController: UIViewController, TraktAuthViewControllerDelegate {

    let trakt = Trakt(clientId: "37558e63c821f673801c2c0788f4f877f5ed626bf5ba4493626173b3ac19b594",
		clientSecret: "9a80ed5b84182af99be0a452696e68e525b2c629e6f2a9a7cd748e4147d85690",
		applicationId: 3695)

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)


		if let auth = TraktAuthViewController.credientialViewController(trakt, delegate: self) {
			navigationController?.presentViewController(auth.embedInNavigationController(), animated: true, completion: nil)
		} else {
			load()
		}
    }

	func load() {
		trakt.trending(.Movies) { (movies, error) -> Void in
			for movie in movies! {
				print(movie.title)
			}
		}
		trakt.trending(.Shows) { (shows, error) -> Void in
			for show in shows! {
				print(show.title)
			}
		}
    }

    func TraktAuthViewControllerDidAuthenticate(controller: UIViewController) {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
        load()
    }

    func TraktAuthViewControllerDidCancel(controller: UIViewController) {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
	}
}
