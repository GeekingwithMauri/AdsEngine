//
//  InterstitialProvider.swift
//  MyStickers
//
//  Created by Mauricio Chirino on 9/10/22.
//  Copyright © 2022 Mauricio Chirino. All rights reserved.
//

import Foundation
import GoogleMobileAds

extension FullScreenAdInsterstitiable {
    var interstitialWrapper: InterstitialAd? {
        interstitial as? InterstitialAd
    }
}

/// Default implementation for AdMob provider on Interstitial ads
final public class InterstitialProvider: NSObject, FullScreenAdInsterstitiable {
    public var adUnitId: String
    
    public var interstitial: NSObject? {
        didSet {
            interstitialWrapper?.fullScreenContentDelegate = self
        }
    }

    weak public var adDelegate: InterstitialInteractable?

    private let autoReload: Bool
    private let requestOptions: AdRequestOptions

    /// Default init
    /// - Parameters:
    ///   - identifier: interstitial's vendor identifier
    ///   - autoReload: whether a dismissed or failed presentation immediately
    ///     requests the next ad. Defaults to `true` — the vendor-recommended
    ///     always-ready posture. A consumer that shows at most one interstitial
    ///     per some external gate (and would otherwise burn a request on an ad
    ///     that never renders) passes `false` and drives `loadAd()` itself.
    ///   - requestOptions: what to stamp on every request. Defaults to a
    ///     personalized request — the vendor default.
    public init(
        identifier: String,
        autoReload: Bool = true,
        requestOptions: AdRequestOptions = .personalized
    ) {
        self.adUnitId = identifier
        self.autoReload = autoReload
        self.requestOptions = requestOptions
    }

    /// Loads the ad on a background queue. Upon load completion, `interstitial` reference is set and `InterstitialInteractable` notifies its listener
    public func loadAd() {
        AdsConfigurator.leaveAudioSessionToTheApp()
        let vendorId = adUnitId
        let request = requestOptions.makeRequest()

        DispatchQueue
            .global(
                qos: .background
            )
            .async {
                InterstitialAd
                    .load(
                        with: vendorId,
                        request: request,
                        completionHandler: {
                            [weak self] loadedAd,
                            error in
                            if let error = error {
                                self?.adDelegate?
                                    .failedToPresent(
                                        dueTo: InterstitialCustomError
                                            .failedInit(
                                                vendorId: vendorId,
                                                additionalContext: error.localizedDescription
                                            )
                                    )
                                return
                            }

                            self?.interstitial = loadedAd
                            self?.adDelegate?.adLoaded()
                        }
                    )
            }
    }
    
    /// Shows the loaded add. Main thread is guaranteed 
    /// - Parameter rootViewController: anchor view controller from where the ad will be launched
    public func showAd(
        from rootViewController: UIViewController
    ) {
        guaranteeMainThread {
            self.interstitialWrapper?
                .present(
                    from: rootViewController
                )
        }
    }
    
}

extension InterstitialProvider: FullScreenContentDelegate {
    /// Tells the delegate that the vendor recorded an impression for the ad.
    /// - Parameter ad: vendor's full screen ad
    public func adDidRecordImpression(
        _ ad: FullScreenPresentingAd
    ) {
        adDelegate?
            .adDidRecordImpression()
    }

    /// Tells the delegate that the ad failed to present full screen content.
    ///
    /// The failed ad is discarded and a fresh one requested: interstitials are
    /// one-shot, so keeping the reference around only guarantees the next
    /// `showAd` fails the same way.
    public func ad(
        _ ad: FullScreenPresentingAd,
        didFailToPresentFullScreenContentWithError error: Error
    ) {
        interstitial = nil
        adDelegate?
            .failedToPresent(
                dueTo: error
            )
        reloadIfAutomatic()
    }

    /// Tells the delegate that the ad dismissed full screen content.
    ///
    /// It also discards the now-consumed ad (presenting it again is an error)
    /// and preloads the next one.
    /// [Source](https://developers.google.com/admob/ios/interstitial#register_for_callbacks)
    public func adDidDismissFullScreenContent(
        _ ad: FullScreenPresentingAd
    ) {
        interstitial = nil
        adDelegate?
            .dismissed()
        reloadIfAutomatic()
    }

    /// The auto-ready posture: after a show ends (dismissed or failed), request
    /// the next ad. Suppressed when the consumer opted out of auto-reload — it
    /// preloads on its own schedule, and an extra request here is one it never
    /// asked for and may never render.
    private func reloadIfAutomatic() {
        guard autoReload else {
            return
        }

        loadAd()
    }
}
