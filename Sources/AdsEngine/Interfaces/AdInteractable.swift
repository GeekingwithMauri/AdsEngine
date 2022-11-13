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

    /// /// Notifies its listener the ad experienced some issues and failed to load on memory
    /// - Parameter error: the culprit for the failure
    func failedToPresent(dueTo error: Error)
}
