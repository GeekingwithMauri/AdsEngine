//
//  AdRequestOptions.swift
//  AdsEngine
//
//  Created by Mauricio Chirino on 08/09/26.
//  Copyright © 2026 Mauricio Chirino. All rights reserved.
//

import GoogleMobileAds

/// What the provider stamps onto every `Request` it builds.
///
/// The seam exists for one reason: a bare `Request()` is a *personalized* ad
/// request. An app that has decided every ad it serves is non-personalized
/// (`npa=1`) — which is what keeps it out of a certified-CMP / ATT requirement,
/// since Google gates only personalized ads behind one — cannot express that
/// through a facade that hardcodes `Request()`. It still serves, so nothing
/// looks broken, while quietly relying on consent machinery that isn't there.
///
/// Kept as a plain `[String: String]` rather than a `Bool` so the same seam
/// carries the next vendor parameter without another API change.
public struct AdRequestOptions: Sendable, Equatable {
    /// Registered on the request as `Extras.additionalParameters`. Empty means a
    /// plain personalized request — the vendor default, unchanged.
    public let additionalParameters: [String: String]

    public init(
        additionalParameters: [String: String] = [:]
    ) {
        self.additionalParameters = additionalParameters
    }

    /// The vendor default: a personalized ad request. Existing consumers get
    /// this without naming it.
    public static let personalized = AdRequestOptions()

    /// Every request carries `npa=1`.
    public static let nonPersonalized = AdRequestOptions(additionalParameters: ["npa": "1"])
}

extension AdRequestOptions {
    /// Builds the vendor request. Internal — consumers describe intent with the
    /// value type and never touch `GoogleMobileAds`.
    func makeRequest() -> Request {
        let request = Request()

        guard !additionalParameters.isEmpty else {
            return request
        }

        let extras = Extras()
        extras.additionalParameters = additionalParameters
        request.register(extras)

        return request
    }
}

/// The banner size the provider asks the vendor for.
///
/// `BannerProvider` used to hardcode this (inline-adaptive at init, then
/// anchored-adaptive at load). The size is the consumer's revenue decision —
/// a fixed 320×50 and an adaptive banner are different inventory — so it comes
/// in through the initializer.
public enum BannerAdSize: Sendable, Equatable {
    /// The fixed 320×50 `AdSizeBanner`.
    case standard

    /// Anchored adaptive for `width`. `nil` defers to the container's own width
    /// at load time, which is the provider's historical behavior.
    case anchoredAdaptive(width: CGFloat?)

    /// Anchored adaptive at the container's width — the pre-seam default.
    public static var anchoredAdaptive: BannerAdSize { .anchoredAdaptive(width: nil) }

    func resolved(containerWidth: CGFloat) -> AdSize {
        switch self {
        case .standard:
            return AdSizeBanner
        case .anchoredAdaptive(let width):
            return currentOrientationAnchoredAdaptiveBanner(width: width ?? containerWidth)
        }
    }

    /// The height the vendor gives this size at `containerWidth` — what a fixed
    /// slot has to reserve. `.standard` is always 50; an adaptive banner's
    /// height is the SDK's answer to the width, not the caller's to guess. Lets
    /// a consumer lay out the slot without importing `GoogleMobileAds`.
    public func height(containerWidth: CGFloat) -> CGFloat {
        resolved(containerWidth: containerWidth).size.height
    }
}
