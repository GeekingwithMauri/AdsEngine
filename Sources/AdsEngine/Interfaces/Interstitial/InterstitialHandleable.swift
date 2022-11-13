//
//  InterstitialHandleable.swift
//  MyStickers
//
//  Created by Mauricio Chirino on 10/10/22.
//  Copyright © 2022 Mauricio Chirino. All rights reserved.
//

import Foundation
import UIKit

/// Type of result from interstitial actions
public typealias CompletionAction = (Result<Void, Error>) -> (Void)

/// Interaction wrapper for interstitials ads
public protocol InterstitialHandleable: AnyObject {
    /// Triggers ad loading. This should be called as soon as possible to prevent latency
    func loadAd()

    /// Shows the ad on full screen. Main thread is highly recommended upon implementation
    /// - Parameter rootViewController: anchor view controller from where the ad will be launched
    func showAd(from rootViewController: UIViewController, onCompletion: @escaping (CompletionAction))
}
