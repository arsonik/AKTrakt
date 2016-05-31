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
    var items: [TraktMovie] = []

    lazy var trakt: Trakt = {
        return Trakt.autoload()
    } ()

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if items.count == 0 {
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
        TraktRequestTrending(type: .Movies, extended: .Images).request(trakt) { [weak self] objects, error in
            if let movies = objects?.flatMap({ $0.media as? TraktMovie }) {
                self?.items = movies
                self?.collectionView.reloadData()
            }
        }
    }

    func loadUser() {
        TraktRequestProfile().request(trakt) { user, error in
            self.title = user?["username"] as? String
        }
        TraktRequestShowProgress(showId: "game-of-thrones").request(trakt) { objects, error in
            print(objects)
        }

        // Recommendations
        TraktRequestRecommendations(type: .Movies, extended: .Images).request(trakt) { [weak self] objects, error in
            if let movies = objects as? [TraktMovie] {
                self?.items = movies
                self?.collectionView.reloadData()
            }
        }
    }

    @IBAction func clearToken(sender: AnyObject) {
        trakt.clearToken()
        title = "Trakt"
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? MovieViewController, movie = sender as? TraktMovie {
            vc.movie = movie
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
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier("movie", forIndexPath: indexPath)
    }

    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if let image = (cell.viewWithTag(1) as? UIImageView), url = items[indexPath.row].imageURL(.Poster, thatFits: image) {
            image.af_setImageWithURL(url, placeholderImage: nil)
        }
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("movie", sender: items[indexPath.row])
    }
}
