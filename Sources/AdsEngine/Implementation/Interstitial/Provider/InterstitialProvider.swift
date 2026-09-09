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

    /// Default init
    /// - Parameter identifier: interstitial's vendor identifier
    public init(
        identifier: String
    ) {
        self.adUnitId = identifier
    }
    
    /// Loads the ad on a background queue. Upon load completion, `interstitial` reference is set and `InterstitialInteractable` notifies its listener
    public func loadAd() {
        AdsConfigurator.leaveAudioSessionToTheApp()
        let vendorId = adUnitId

        DispatchQueue
            .global(
                qos: .background
            )
            .async {
                InterstitialAd
                    .load(
                        with: vendorId,
                        request: Request(),
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
    
    deinit {
        print(
            "+++++ Deallocated interstitial ++++++"
        )
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
        loadAd()
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
        loadAd()
    }
}
