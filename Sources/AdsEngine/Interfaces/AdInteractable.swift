//
//  AdInteractable.swift
//  
//
//  Created by Mauricio Chirino on 6/11/22.
//

import Foundation

/// Interactions from ads
public protocol AdInteractable: AnyObject {
    /// Notifies its listener the ad has been fully loaded on memory
    func adLoaded()

    /// Notifies its listener the ad experienced some issues and failed to load on memory
    /// - Parameter error: the culprit for the failure
    func failedToPresent(dueTo error: Error)

    /// Notifies its listener the vendor recorded an impression for the ad.
    ///
    /// This is the vendor's own "the ad was actually seen" signal, which is
    /// strictly later and rarer than ``adLoaded()``: an ad can load and never be
    /// rendered. Callers that count ad exposure want this one.
    ///
    /// Nothing about *where* the ad sits is reported here — placement taxonomy
    /// belongs to the caller, which is the only side that knows its own screens.
    func adDidRecordImpression()
}

public extension AdInteractable {
    /// Impressions are opt-in: a conformer that doesn't care about them keeps
    /// compiling untouched when this protocol gains the callback.
    func adDidRecordImpression() {}
}
