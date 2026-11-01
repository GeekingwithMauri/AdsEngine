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
    private let placement: String?
    private let loadStrategy: AdLoadStrategy?

    /// Banner delegate to notify its listener of ad events. The vendor view's
    /// delegate is this provider, attached by the loader on every load.
    public weak var adDelegate: AdInteractable?

    /// Default init
    /// - Parameters:
    ///   - identifier: banner's vendor identifier
    ///   - size: the ad size to request. Defaults to anchored-adaptive at the
    ///     container's width, which is what this provider always did.
    ///   - requestOptions: what to stamp on every request. Defaults to a
    ///     personalized request — the vendor default.
    ///   - placement: a stable label for where the banner shows, for event
    ///     reporting. Never a dynamic value.
    ///   - loadStrategy: how the request reaches the vendor. `nil` reads
    ///     `AdsConfigurator.loadStrategy` on every load.
    public init(
        identifier: String,
        size: BannerAdSize = .anchoredAdaptive,
        requestOptions: AdRequestOptions = .personalized,
        placement: String? = nil,
        loadStrategy: AdLoadStrategy? = nil
    ) {
        self.identifier = identifier
        self.size = size
        self.requestOptions = requestOptions
        self.placement = placement
        self.loadStrategy = loadStrategy
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
        pin(in: view)
    }

    /// Moves the banner, loaded or loading, into another container and
    /// presents its click-through from `rootViewController`. Its ad is kept:
    /// nothing is requested. For a banner loaded before the screen that shows
    /// it exists.
    /// - Parameters:
    ///   - view: the new container, filled the same way as the first
    ///   - rootViewController: the controller that now holds the banner
    public func rehost(
        in view: UIView,
        rootViewController: UIViewController
    ) {
        bannerView.removeFromSuperview()
        pin(in: view)
        bannerViewWrapper?.rootViewController = rootViewController
    }

    private func pin(
        in view: UIView
    ) {
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
        guard let bannerViewWrapper else {
            return
        }

        (loadStrategy ?? AdsConfigurator.loadStrategy(placement)).banner(
            bannerViewWrapper,
            requestOptions.makeRequest(),
            self
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
