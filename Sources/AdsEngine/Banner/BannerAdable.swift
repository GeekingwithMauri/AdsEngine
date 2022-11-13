//
//  BannerView.swift
//  MyStickers
//
//  Created by Mauricio Chirino on 28/10/22.
//  Copyright © 2022 Mauricio Chirino. All rights reserved.
//

import Foundation
import UIKit

public protocol AdInteractable: AnyObject {
    func adLoaded()
    func failedToPresent(dueTo error: Error)
}

public protocol BannerAdable {
    var identifier: String { get }
    var bannerView: UIView { get set }
    var adDelegate: AdInteractable? { get set }

    func initBannerToBeIncluded(in view: UIView)
    func loadAd(for rootViewController: UIViewController)
}
