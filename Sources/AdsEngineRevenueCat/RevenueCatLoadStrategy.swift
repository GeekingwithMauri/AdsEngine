//
//  RevenueCatLoadStrategy.swift
//  AdsEngineRevenueCat
//

import AdsEngine
import GoogleMobileAds
import RevenueCatAdMob

public extension AdLoadStrategy {
    /// Loads through RevenueCat's AdMob adapter, which reports each ad's
    /// loaded, displayed, opened, revenue and failed-to-load events to
    /// RevenueCat under `placement`, then forwards every callback unchanged.
    ///
    /// The adapter drops events until `Purchases` is configured. Revenue needs
    /// impression-level ad revenue turned on in the AdMob account.
    ///
    /// - Parameter placement: a stable label for where the ad shows, such as
    ///   `"home_banner"`. Never a dynamic value.
    static func revenueCat(placement: String) -> AdLoadStrategy {
        AdLoadStrategy(
            banner: { view, request, delegate in
                view.loadAndTrack(
                    request: request,
                    placement: placement,
                    delegate: delegate
                )
            },
            interstitial: { adUnitID, request, delegate, completion in
                InterstitialAd.loadAndTrack(
                    withAdUnitID: adUnitID,
                    request: request,
                    placement: placement,
                    fullScreenContentDelegate: delegate
                ) { ad, error in
                    completion(
                        ad,
                        error
                    )
                }
            }
        )
    }
}
