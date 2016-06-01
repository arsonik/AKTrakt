//
//  ViewController.swift
//  AKTrakt_TvOS_Example
//
//  Created by Florian Morello on 25/11/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import UIKit
import AKTrakt
import AlamofireImage

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    var movies: [TraktMovie] = []
    var shows: [TraktShow] = []

    lazy var trakt: Trakt = {
        return Trakt.autoload()
    } ()

    var loadedOnce: Bool = false

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if !loadedOnce {
            load()
        }

        if trakt.hasValidToken() {
            loadUser()
        }
    }

    @IBAction func displayAuth() {
        if let vc = TraktAuthenticationViewController.credientialViewController(trakt, delegate: self) {
            presentViewController(vc, animated: true, completion: nil)
        }
    }

    func load() {
        loadedOnce = true
        TraktRequestTrending(type: TraktMovie.self, extended: .Images, pagination: TraktPagination(page: 1, limit: 10)).request(trakt) { [weak self] objects, error in
            if let movies = objects?.flatMap({ $0.media }) {
                self?.movies = movies
                self?.collectionView.reloadSections(NSIndexSet(index: 0))
            } else {
                print(error)
            }
        }
        TraktRequestTrending(type: TraktShow.self, extended: .Images, pagination: TraktPagination(page: 1, limit: 20)).request(trakt) { [weak self] objects, error in
            if let shows = objects?.flatMap({ $0.media }) {
                self?.shows = shows
                self?.collectionView.reloadSections(NSIndexSet(index: 1))
            } else {
                print(error)
            }
        }
    }

    func loadUser() {
        TraktRequestProfile().request(trakt) { user, error in
            self.title = user?["username"] as? String
        }
    }

    @IBAction func clearToken(sender: AnyObject) {
        trakt.clearToken()
        title = "Trakt"
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? MovieViewController, movie = sender as? TraktMovie {
            vc.movie = movie
        } else if let vc = segue.destinationViewController as? ShowViewController, show = sender as? TraktShow {
            vc.show = show
        }
    }
}

extension ViewController: TraktAuthViewControllerDelegate {
    func TraktAuthViewControllerDidAuthenticate(controller: UIViewController) {
        loadUser()
        dismissViewControllerAnimated(true, completion: nil)
    }

    func TraktAuthViewControllerDidCancel(controller: UIViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? movies.count : shows.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier("movie", forIndexPath: indexPath)
    }

    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            if let image = (cell.viewWithTag(1) as? UIImageView), url = movies[indexPath.row].imageURL(.Poster, thatFits: image) {
                image.af_setImageWithURL(url, placeholderImage: nil)
            }
        } else if let image = (cell.viewWithTag(1) as? UIImageView), url = shows[indexPath.row].imageURL(.Poster, thatFits: image) where indexPath.section == 1 {
            image.af_setImageWithURL(url, placeholderImage: nil)
        }
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            performSegueWithIdentifier("movie", sender: movies[indexPath.row])
        } else {
            performSegueWithIdentifier("show", sender: shows[indexPath.row])
        }
    }
}
