//
//  MediationPrivacy.swift
//  AdsEngineMediation
//

import UnityAds
import VungleAdsSDK

/// Privacy signals for the mediated networks.
///
/// `npa=1` on the Google request binds Google only: "Google is unable to apply
/// this setting to each ad network in your mediation chain." Each network
/// takes its own signal.
public enum MediationPrivacy {
    /// Tells every linked network the user has not consented to personalised
    /// ads and has opted out of the sale of their data. Call it before
    /// `AdsConfigurator.start()` and before the first ad request.
    ///
    /// Both networks document the call at developers.google.com/admob/ios/mediation
    /// (`/liftoff-monetize` and `/unity`, § privacy):
    /// - Liftoff Monetize: `VunglePrivacySettings.setCCPAStatus(_ optIn:)` and
    ///   `setGDPRStatus(_ optIn:)`. `true` is opt-in, so `false` is passed to both.
    /// - Unity Ads: the page shows `UADSMetaData` `privacy.consent`, which the SDK
    ///   now deprecates. Its headers name three replacements, each set here:
    ///   `setNonBehavioral(true)` ("Enables the display of contextual
    ///   (non-personalized) ads"), `setUserOptOut(true)` (opts out of data
    ///   collection) and `setUserConsent(false)` (no consent for personalised ads).
    ///
    /// Neither vendor exposes a getter, so the call cannot be read back.
    public static func optOutOfPersonalisedAds() {
        VunglePrivacySettings.setCCPAStatus(false)
        VunglePrivacySettings.setGDPRStatus(false)
        UnityAds.setNonBehavioral(true)
        UnityAds.setUserOptOut(true)
        UnityAds.setUserConsent(false)
    }
}
