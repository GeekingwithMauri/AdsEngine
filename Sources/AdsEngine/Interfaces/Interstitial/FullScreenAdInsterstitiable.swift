//
//  FullScreenAdInsterstitiable.swift
//  MyStickers
//
//  Created by Mauricio Chirino on 9/10/22.
//  Copyright © 2022 Mauricio Chirino. All rights reserved.
//

import Foundation
import UIKit

/// Delegate for interstitial interaction
public protocol InterstitialInteractable: AdInteractable {
    /// Notifies whenever the interstitial ad was dismissed
    func dismissed()
}

/// Interstitial ad wrapper
public protocol FullScreenAdInsterstitiable: AnyObject {
    /// Ad identifier
    var adUnitId: String { get }

    /// Ad object reference. Once set, it binds with 3rd-party ad's interaction delegate
    var interstitial: NSObject? { get set }

    /// Ad's delegate
    var adDelegate: InterstitialInteractable? { get set }

    /// Triggers ad loading. This should be called as soon as possible to prevent latency
    func loadAd()

    /// Shows the ad on full screen. Main thread is highly recommended upon implementation 
    /// - Parameter rootViewController: anchor view controller from where the ad will be launched
    func showAd(from rootViewController: UIViewController)
}
