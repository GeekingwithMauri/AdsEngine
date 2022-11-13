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

final class BannerProvider: NSObject, BannerAdable {
    var identifier: String
    var bannerView: UIView

    var adDelegate: AdInteractable? {
        didSet {
            bannerViewWrapper?.delegate = self
        }
    }

    init(identifier: String) {
        self.identifier = identifier
        bannerView = UIView(frame: .zero)
    }

    func initBannerToBeIncluded(in view: UIView) {
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

    func loadAd(for rootViewController: UIViewController) {
        bannerViewWrapper?.adUnitID = identifier
        bannerViewWrapper?.rootViewController = rootViewController
        bannerViewWrapper?.load(GADRequest())
    }
}

extension BannerProvider: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        adDelegate?.adLoaded()
        bannerView.alpha = 0

        UIView.animate(withDuration: 1) {
            bannerView.alpha = 1
        }
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        adDelegate?.failedToPresent(dueTo: error)
    }
}

