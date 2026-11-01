//
//  RevenueCatLoadStrategy.swift
//  AdsEngineRevenueCat
//

import AdsEngine
import GoogleMobileAds
import RevenueCatAdMob

/// Reports every provider's ad events to RevenueCat, behind the providers'
/// own API: callers keep building `BannerProvider` and `InterstitialProvider`
/// with a `placement:` and never touch this product.
public enum RevenueCatAdTracking {
    /// Routes every provider built without its own `loadStrategy` through
    /// RevenueCat's AdMob adapter. Call once at launch, before the first
    /// `loadAd`.
    ///
    /// The adapter drops events until `Purchases` is configured. Revenue needs
    /// impression-level ad revenue turned on in the AdMob account.
    public static func enable() {
        AdsConfigurator.loadStrategy = { placement in
            .tracked(placement: placement)
        }
    }
}

public extension AdLoadStrategy {
    /// Loads through RevenueCat's AdMob adapter, which reports each ad's
    /// loaded, displayed, opened, revenue and failed-to-load events to
    /// RevenueCat under `placement`, then forwards every callback unchanged.
    ///
    /// - Parameter placement: a stable label for where the ad shows, such as
    ///   `"home_banner"`. Never a dynamic value.
    static func revenueCat(placement: String) -> AdLoadStrategy {
        tracked(placement: placement)
    }
}

extension AdLoadStrategy {
    static func tracked(placement: String?) -> AdLoadStrategy {
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
