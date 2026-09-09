//
//  BannerProvider.swift
//  MyStickers
//
//  Created by Mauricio Chirino on 29/10/22.
//  Copyright © 2022 Mauricio Chirino. All rights reserved.
//

import GoogleMobileAds

extension BannerProvider {
    var bannerViewWrapper: BannerView? {
        bannerView as? BannerView
    }
}

/// Default implementation for AdMob provider on Banner ads
final public class BannerProvider: NSObject, BannerAdable {
    public var identifier: String
    public var bannerView: UIView

    private let size: BannerAdSize
    private let requestOptions: AdRequestOptions

    /// Banner delegate to notify its listener of ad events
    public weak var adDelegate: AdInteractable? {
        didSet {
            bannerViewWrapper?.delegate = self
        }
    }

    /// Default init
    /// - Parameters:
    ///   - identifier: banner's vendor identifier
    ///   - size: the ad size to request. Defaults to anchored-adaptive at the
    ///     container's width, which is what this provider always did.
    ///   - requestOptions: what to stamp on every request. Defaults to a
    ///     personalized request — the vendor default.
    public init(
        identifier: String,
        size: BannerAdSize = .anchoredAdaptive,
        requestOptions: AdRequestOptions = .personalized
    ) {
        self.identifier = identifier
        self.size = size
        self.requestOptions = requestOptions
        bannerView = UIView(
            frame: .zero
        )
    }

    /// Initializes the ad
    /// - Parameter view: container view where the ad will be placed and filled its entirety
    public func initBannerToBeIncluded(
        in view: UIView
    ) {
        bannerView = BannerView(
            adSize: size.resolved(
                containerWidth: view.bounds.width
            )
        )
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view
            .addSubview(
                bannerView
            )
        
        NSLayoutConstraint
            .activate(
                [
                    bannerView.topAnchor
                        .constraint(
                            equalTo: view.topAnchor
                        ),
                    bannerView.bottomAnchor
                        .constraint(
                            equalTo: view.bottomAnchor
                        ),
                    bannerView.centerXAnchor
                        .constraint(
                            equalTo: view.centerXAnchor
                        ),
                    bannerView.widthAnchor
                        .constraint(
                            equalTo: view.widthAnchor
                        )
                ]
            )
    }
    
    public func loadAd(
        for rootViewController: UIViewController
    ) {
        AdsConfigurator.leaveAudioSessionToTheApp()
        bannerViewWrapper?.adUnitID = identifier
        bannerViewWrapper?.adSize = size.resolved(
            containerWidth: bannerView.frame.width
        )
        bannerViewWrapper?.rootViewController = rootViewController
        bannerViewWrapper?
            .load(
                requestOptions.makeRequest()
            )
    }
}

extension BannerProvider: BannerViewDelegate {
    /// Notifies its listener that the banner was fully loaded. It's rendered in an fade in animated fashion
    /// - Parameter bannerView: vendor's banner view
    public func bannerViewDidReceiveAd(
        _ bannerView: BannerView
    ) {
        adDelegate?
            .adLoaded()
        bannerView.alpha = 0
        
        UIView
            .animate(
                withDuration: 1
            ) {
                bannerView.alpha = 1
            }
    }
    
    /// Tells the delegate that the vendor recorded an impression for the banner.
    /// - Parameter bannerView: vendor's banner view
    public func bannerViewDidRecordImpression(
        _ bannerView: BannerView
    ) {
        adDelegate?
            .adDidRecordImpression()
    }

    /// Tells the delegate that the ad failed to present full screen content.
    /// - Parameters:
    ///   - bannerView: vendor's banner view
    ///   - error: culprit of the failure
    public func bannerView(
        _ bannerView: BannerView,
        didFailToReceiveAdWithError error: Error
    ) {
        adDelegate?
            .failedToPresent(
                dueTo: error
            )
    }
}
