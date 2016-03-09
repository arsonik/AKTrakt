//
//  TvOsTraktAuthViewController.swift
//  Pods
//
//  Created by Florian Morello on 30/10/15.
//
//

import UIKit

extension String {
	func stringByAddingPercentEncodingForURLQueryValue() -> String? {
		let allowedCharacters = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
		return self.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacters)
	}
}

extension Dictionary {
	func stringFromHttpParameters() -> String {
		let parameterArray = self.map { (key, value) -> String in
			let percentEscapedKey = (key as! String).stringByAddingPercentEncodingForURLQueryValue()!
			let percentEscapedValue = (value as! String).stringByAddingPercentEncodingForURLQueryValue()!
			return "\(percentEscapedKey)=\(percentEscapedValue)"
		}

		return parameterArray.joinWithSeparator("&")
	}

}

public class TvOsTraktAuthViewController : UIViewController, UITextFieldDelegate {

    @IBOutlet weak var qrImageView: UIImageView!
	@IBOutlet weak var pinField: UITextField!
	@IBOutlet weak var uriLabel: UILabel!
	@IBOutlet weak var infoLabel: UILabel!
	@IBOutlet weak var activity: UIActivityIndicatorView!

    internal weak var delegate: TraktAuthViewControllerDelegate!
    internal var trakt: Trakt!

    public override func viewDidLoad() {
        super.viewDidLoad()

		activity.stopAnimating()

		// Use QRCode lib instead
		let redirectTo = "https://trakt.tv/pin/\(trakt.applicationId)"
        qrImageView.image = UIImage(named: "TraktQRCode.png", inBundle: TvOsTraktAuthViewController.bundle, compatibleWithTraitCollection: nil)
		uriLabel.text = redirectTo
		infoLabel.text = String(format: "Please authorize %@\n to access your Trakt.tv account", NSBundle.mainBundle().infoDictionary!["CFBundleName"] as! String)
    }

    static var bundle: NSBundle? {
        return NSBundle(forClass: TvOsTraktAuthViewController.self)
    }

    public func textFieldShouldReturn(textField: UITextField) -> Bool {
		guard let pinEntry = textField.text else {
			return true
		}
		activity.startAnimating()
        trakt.exchangePinForToken(pinEntry) { [weak self] token, error in
            if token != nil {
                self?.trakt.saveToken(token: token)
                self?.delegate?.TraktAuthViewControllerDidAuthenticate(self!)
            } else {

				let ac = UIAlertController(title: "Trakt Error", message: error?.localizedDescription, preferredStyle: .Alert)
				ac.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { (action) -> Void in
					self?.navigationController?.dismissViewControllerAnimated(true, completion: nil)
				}))
				self?.presentViewController(ac, animated: true, completion: nil)
			}
			self?.activity.stopAnimating()
        }
        return true
    }

	public static func credientialViewController(trakt: Trakt, delegate: TraktAuthViewControllerDelegate) -> TvOsTraktAuthViewController? {
		if trakt.token == nil {
			let vc = TvOsTraktAuthViewController(nibName: "TvOsTraktAuthViewController", bundle: TvOsTraktAuthViewController.bundle)
			vc.delegate = delegate
			vc.trakt = trakt
			return vc
		}
		return nil
	}
}