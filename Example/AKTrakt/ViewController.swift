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

    var trakt:Trakt!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        trakt = Trakt(clientId: "37558e63c821f673801c2c0788f4f877f5ed626bf5ba4493626173b3ac19b594", clientSecret: "9a80ed5b84182af99be0a452696e68e525b2c629e6f2a9a7cd748e4147d85690", applicationId: 3695)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if !trakt.hasToken {
            let authVC = TraktAuthViewController(trakt: trakt, delegate: self)
            navigationController?.presentViewController(authVC.embedInNavigationController(), animated: true, completion: nil)
        }
        else {
            load()
        }
    }

    func load() {
        trakt.trendingMovies { (movies, error) -> Void in
            for movie in movies! {
                print(movie.title)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

