//
//  AdsConfigurator.swift
//  AdsEngine
//
//  Created by Mauricio Chirino on 02/08/26.
//  Copyright © 2026 Mauricio Chirino. All rights reserved.
//

import GoogleMobileAds

/// One-time SDK configuration that must run before the first ad request.
public enum AdsConfigurator {
    /// The strategy a provider built without one loads with, given its
    /// placement. Read on every load, so a change reaches providers that
    /// already exist. Defaults to the vendor's own call; an opt-in product
    /// replaces it once at launch, before the first `loadAd`.
    public static var loadStrategy: (_ placement: String?) -> AdLoadStrategy = { _ in
        .vendor
    }

    /// Registers physical devices that should receive Google test ads on live
    /// ad units. Pass the hashed ids the SDK prints to the console on the
    /// device's first ad request ("To get test ads on this device, set: …").
    /// Simulators always receive test ads and never need registering.
    public static func registerTestDevices(
        _ identifiers: [String]
    ) {
        MobileAds.shared.requestConfiguration.testDeviceIdentifiers = identifiers
    }

    /// Starts the Google Mobile Ads SDK. Bidding mediation adapters need it
    /// running before the first request, so call it once at launch, after any
    /// privacy configuration and before the first `loadAd`. Calling it again is
    /// harmless: the vendor ignores repeat starts.
    public static func start() {
        guaranteeMainThread {
            MobileAds.shared.start(completionHandler: nil)
        }
    }

    /// Leaves the process's `AVAudioSession` to the host app.
    ///
    /// `audioSessionIsApplicationManaged` ships as `false`, and the vendor spells out
    /// what it then does: sets the category to `.ambient` while its videos are muted,
    /// and to `.soloAmbient` when one unmutes. **Both are silenced by the Ring/Silent
    /// switch.** So an app that deliberately plays through a silenced phone — game
    /// sound, a meditation cue — goes quiet the moment an ad is requested, and stays
    /// quiet, because nothing puts its category back.
    ///
    /// On by default rather than an opt-in a consumer has to know exists: an ads
    /// library reaching into the host's audio session is the surprise, not this. The
    /// SDK keeps driving audio for its own video creatives either way — the flag only
    /// stops it rewriting the app's category around them. A consumer that genuinely
    /// wants the vendor holding the session sets the property back itself.
    ///
    /// Idempotent, so every ad request can call it and no one-shot latch is needed.
    /// Main thread is the vendor's requirement, not ours.
    static func leaveAudioSessionToTheApp() {
        guaranteeMainThread {
            MobileAds.shared.audioVideoManager.isAudioSessionApplicationManaged = true
        }
    }
}
