//
//  BannerProvider.swift
//  MyStickers
//
//  Created by Mauricio Chirino on 29/10/22.
//  Copyright © 2022 Mauricio Chirino. All rights reserved.
//

import GoogleMobileAds

extension BannerProvider {
    var bannerViewWrapper: GADBannerView? {
        bannerView as? GADBannerView
    }
}

/// Default implementation for AdMob provider on Banner ads
final public class BannerProvider: NSObject, BannerAdable {
    public var identifier: String
    public var bannerView: UIView

    /// Banner delegate to notify its listener of ad events
    public weak var adDelegate: AdInteractable? {
        didSet {
            bannerViewWrapper?.delegate = self
        }
    }

    /// Default init
    /// - Parameter identifier: banner's vendor identifier
    public init(identifier: String) {
        self.identifier = identifier
        bannerView = UIView(frame: .zero)
    }

    /// Initializes the ad
    /// - Parameter view: container view where the ad will be placed and filled its entirety
    public func initBannerToBeIncluded(in view: UIView) {
        bannerView = GADBannerView(
            adSize: GADCurrentOrientationInlineAdaptiveBannerAdSizeWithWidth(view.bounds.width)
        )
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)

        NSLayoutConstraint.activate([
            bannerView.topAnchor.constraint(equalTo: view.topAnchor),
            bannerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bannerView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
    }

    public func loadAd(for rootViewController: UIViewController) {
        bannerViewWrapper?.adUnitID = identifier
        bannerViewWrapper?.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(bannerView.frame.width)
        bannerViewWrapper?.rootViewController = rootViewController
        bannerViewWrapper?.load(GADRequest())
    }
}

extension BannerProvider: GADBannerViewDelegate {
    /// Notifies its listener that the banner was fully loaded. It's rendered in an fade in animated fashion
    /// - Parameter bannerView: vendor's banner view
    public func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        adDelegate?.adLoaded()
        bannerView.alpha = 0

        UIView.animate(withDuration: 1) {
            bannerView.alpha = 1
        }
    }

    /// Tells the delegate that the ad failed to present full screen content.
    /// - Parameters:
    ///   - bannerView: vendor's banner view
    ///   - error: culprit of the failure
    public func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        adDelegate?.failedToPresent(dueTo: error)
    }
}
