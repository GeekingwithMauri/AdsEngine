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
    /// Registers physical devices that should receive Google test ads on live
    /// ad units. Pass the hashed ids the SDK prints to the console on the
    /// device's first ad request ("To get test ads on this device, set: …").
    /// Simulators always receive test ads and never need registering.
    public static func registerTestDevices(
        _ identifiers: [String]
    ) {
        MobileAds.shared.requestConfiguration.testDeviceIdentifiers = identifiers
    }
}
