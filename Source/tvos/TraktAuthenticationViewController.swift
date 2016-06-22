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

	var intervalTimer: Timer?
	var responseCode: GeneratedCodeResponse? {
		didSet {
			intervalTimer?.invalidate()
			if responseCode != nil {
				uriLabel?.text = responseCode!.verificationUrl
				codeLabel?.text = responseCode!.userCode
				intervalTimer = Timer.scheduledTimer(timeInterval: responseCode!.interval, target: self, selector: #selector(TraktAuthenticationViewController.poll(_:)), userInfo: nil, repeats: true)
			}
		}
	}

	public override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)

		getNewCode()
		qrImageView.image = UIImage(named: "TraktQRCode.png", in: TraktAuthenticationViewController.bundle, compatibleWith: nil)
	}

	public override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		intervalTimer?.invalidate()
	}

	private func getNewCode() {
		activity.startAnimating()

        TraktRequestGenerateCode(clientId: trakt.clientId).request(trakt) { [weak self] data, error in
            self?.responseCode = data
            self?.activity.stopAnimating()
            if data == nil {
                let ac = UIAlertController(title: "Trakt Error", message: error?.localizedDescription, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self?.present(ac, animated: true, completion: nil)
            }
        }
	}

    static var bundle: Bundle? {
        return Bundle(for: TraktAuthenticationViewController.self)
    }

	public func poll(_ timer: Timer) {
		if responseCode?.expiresAt.compare(Date()) == .orderedAscending || responseCode == nil {
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

	public static func credientialViewController(_ trakt: Trakt, delegate: TraktAuthViewControllerDelegate) -> UIViewController? {
		if !trakt.hasValidToken() {
			let vc = TraktAuthenticationViewController(nibName: "TraktAuthenticationViewController", bundle: TraktAuthenticationViewController.bundle)
			vc.delegate = delegate
			vc.trakt = trakt
			return vc
		}
		return nil
	}
}
