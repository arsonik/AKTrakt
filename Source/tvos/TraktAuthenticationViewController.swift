//
//  TraktAuthenticationViewController.swift
//  Arsonik
//
//  Created by Florian Morello on 30/10/15.
//
//

import UIKit

public class TraktAuthenticationViewController: UIViewController {
    @IBOutlet weak var qrImageView: UIImageView!
	@IBOutlet weak var codeLabel: UILabel!
	@IBOutlet weak var uriLabel: UILabel!
	@IBOutlet weak var infoLabel: UILabel!
	@IBOutlet weak var activity: UIActivityIndicatorView!

    internal weak var delegate: TraktAuthViewControllerDelegate!
    internal var trakt: Trakt!

	var intervalTimer: NSTimer?
	var responseCode: GeneratedCodeResponse? {
		didSet {
			intervalTimer?.invalidate()
			if responseCode != nil {
				uriLabel?.text = responseCode!.verificationUrl
				codeLabel?.text = responseCode!.userCode
				intervalTimer = NSTimer.scheduledTimerWithTimeInterval(responseCode!.interval, target: self, selector: #selector(TraktAuthenticationViewController.poll(_:)), userInfo: nil, repeats: true)
			}
		}
	}

	public override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(true)

		getNewCode()
		qrImageView.image = UIImage(named: "TraktQRCode.png", inBundle: TraktAuthenticationViewController.bundle, compatibleWithTraitCollection: nil)
	}

	public override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)

		intervalTimer?.invalidate()
	}

	private func getNewCode() {
		activity.startAnimating()

        TraktRequestGenerateCode(clientId: trakt.clientId).request(trakt) { [weak self] data, error in
            self?.responseCode = data
            self?.activity.stopAnimating()
            if data == nil {
                let ac = UIAlertController(title: "Trakt Error", message: error?.localizedDescription, preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                self?.presentViewController(ac, animated: true, completion: nil)
            }
        }
	}

    static var bundle: NSBundle? {
        return NSBundle(forClass: TraktAuthenticationViewController.self)
    }

	public func poll(timer: NSTimer) {
		if responseCode?.expiresAt.compare(NSDate()) == .OrderedAscending || responseCode == nil {
			timer.invalidate()
			getNewCode()
		} else {
			activity.startAnimating()

            TraktRequestPollDevice(trakt: trakt, deviceCode: responseCode!.deviceCode).request(trakt) { [weak self] token, error in
                self?.activity.stopAnimating()
                if token != nil {
                    timer.invalidate()
                    self?.trakt.saveToken(token!)
                    self?.delegate?.TraktAuthViewControllerDidAuthenticate(self!)
                }
            }
		}
	}

	public static func credientialViewController(trakt: Trakt, delegate: TraktAuthViewControllerDelegate) -> UIViewController? {
		if !trakt.hasValidToken() {
			let vc = TraktAuthenticationViewController(nibName: "TraktAuthenticationViewController", bundle: TraktAuthenticationViewController.bundle)
			vc.delegate = delegate
			vc.trakt = trakt
			return vc
		}
		return nil
	}
}
