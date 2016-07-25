//
//  ViewController.swift
//  AKTrakt_TvOS_Example
//
//  Created by Florian Morello on 25/11/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import UIKit
import AlamofireImage

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    var movies: [TraktMovie] = []
    var shows: [TraktShow] = []

    lazy var trakt: Trakt = {
        return Trakt.autoload()
    } ()

    var loadedOnce: Bool = false

    override func viewDidAppear(_ animated: Bool) {
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
            present(vc, animated: true, completion: nil)
        }
    }

    func load() {
        loadedOnce = true
        TraktRequestTrending(type: TraktMovie.self, extended: .Images, pagination: TraktPagination(page: 1, limit: 10)).request(trakt) { [weak self] objects, error in
            if let movies = objects?.flatMap({ $0.media }) {
                self?.movies = movies
                self?.collectionView.reloadSections(IndexSet(integer: 0))
            } else {
                print(error)
            }
        }
        TraktRequestTrending(type: TraktShow.self, extended: .Images, pagination: TraktPagination(page: 1, limit: 20)).request(trakt) { [weak self] objects, error in
            if let shows = objects?.flatMap({ $0.media }) {
                self?.shows = shows
                self?.collectionView.reloadSections(IndexSet(integer: 1))
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

    @IBAction func clearToken(_ sender: AnyObject) {
        trakt.clearToken()
        title = "Trakt"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? MovieViewController, let movie = sender as? TraktMovie {
            vc.movie = movie
        } else if let vc = segue.destinationViewController as? ShowViewController, let show = sender as? TraktShow {
            vc.show = show
        }
    }
}

extension ViewController: TraktAuthViewControllerDelegate {
    func TraktAuthViewControllerDidAuthenticate(_ controller: UIViewController) {
        loadUser()
        dismiss(animated: true, completion: nil)
    }

    func TraktAuthViewControllerDidCancel(_ controller: UIViewController) {
        dismiss(animated: true, completion: nil)
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? movies.count : shows.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "movie", for: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 0 {
            if let image = (cell.viewWithTag(1) as? UIImageView), let url = movies[indexPath.row].imageURL(.Poster, thatFits: image) {
                image.af_setImageWithURL(url, placeholderImage: nil)
            }
        } else if let image = (cell.viewWithTag(1) as? UIImageView), let url = shows[indexPath.row].imageURL(.Poster, thatFits: image) where (indexPath as NSIndexPath).section == 1 {
            image.af_setImageWithURL(url, placeholderImage: nil)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 0 {
            performSegue(withIdentifier: "movie", sender: movies[indexPath.row])
        } else {
            performSegue(withIdentifier: "show", sender: shows[indexPath.row])
        }
    }
}
