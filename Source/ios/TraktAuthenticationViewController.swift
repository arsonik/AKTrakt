//
//  TraktAuthenticationViewController.swift
//  Arsonik
//
//  Created by Florian Morello on 09/04/15.
//  Copyright (c) 2015 Florian Morello. All rights reserved.
//

import UIKit
import WebKit
import Alamofire

public class TraktAuthenticationViewController: UIViewController, WKNavigationDelegate {

    private var wkWebview: WKWebView!
	private weak var delegate: TraktAuthViewControllerDelegate!
	private let trakt: Trakt

    public init(trakt: Trakt, delegate: TraktAuthViewControllerDelegate) {
        self.trakt = trakt
        self.delegate = delegate

        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(TraktAuthenticationViewController.cancel))

        wkWebview = WKWebView(frame: view.bounds)
        wkWebview.navigationDelegate = self

        view.addSubview(wkWebview)

        initWebview()
    }

	public static func credientialViewController(_ trakt: Trakt, delegate: TraktAuthViewControllerDelegate) -> UIViewController? {
		if !trakt.hasValidToken() {
			return UINavigationController(rootViewController: TraktAuthenticationViewController(trakt: trakt, delegate: delegate))
		}
		return nil
	}

    @IBAction public func cancel() {
        delegate?.TraktAuthViewControllerDidCancel(self)
    }

    private func initWebview() {
        wkWebview.load(URLRequest(url: URL(string: "http://trakt.tv/pin/\(trakt.applicationId)")!))
    }

    private func pinFromNavigation(_ action: WKNavigationAction) -> String? {
        if let path = action.request.url?.path, path.contains("/oauth/authorize/") {
            let folders = path.components(separatedBy: "/")
            return folders[3]
        }
        return nil
    }

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        if let pin = pinFromNavigation(navigationAction) {
            decisionHandler(.cancel)
            TraktRequestToken(trakt: trakt, pin: pin).request(trakt) { token, error in
                guard token != nil else {
                    let ac = UIAlertController(title: "", message: "Failed to get a valid token", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(ac, animated: true, completion: nil)
                    self.initWebview()
                    return
                }

                self.trakt.saveToken(token!)
                self.delegate?.TraktAuthViewControllerDidAuthenticate(self)
            }
            return ()
        }
        decisionHandler(WKNavigationActionPolicy.allow)
    }

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        print(error)
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: NSError) {
        print(error)
    }
}
