//
//  BannerView.swift
//  MyStickers
//
//  Created by Mauricio Chirino on 28/10/22.
//  Copyright © 2022 Mauricio Chirino. All rights reserved.
//

import Foundation
import UIKit

/// Interaction wrapper for banner ads
public protocol BannerAdable {
    /// Ad identifier
    var identifier: String { get }

    /// Ad object reference.
    var bannerView: UIView { get set }

    /// Ad's delegate.
    var adDelegate: AdInteractable? { get set }

    /// Initializes the ad
    /// - Parameter view: container view where the add will be placed.
    func initBannerToBeIncluded(in view: UIView)

    /// Triggers ad loading. This should be called as soon as possible to prevent latency
    /// - Parameter rootViewController: anchor view controller from where the ad will be shown
    func loadAd(for rootViewController: UIViewController)
}
