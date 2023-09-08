# AdsEngine

## Rationale

Ideally, we want to have our code completely dependency-free and preserve control over its entire functioning. In the real world, we know this is unrealistic since it would imply reinventing the wheel over and over. 

_AdsEngine_ centralizes the ad's SDKs and exposes them via facades.

## What's the point?
Contracts expire, SDKs get deprecated and fees rises. These, just to mention a few, are valid reasons to change ad's vendors. 

This is rather hard when our codebases are littered with direct SDKs implementations. _AdsEngine_ makes such processes painless by making their consumption behind a facade. This is why, whatever happens under the hood shall not concern our clients apps.

## Installation 
### Xcode 13
 1. From the **File** menu, **Add Packages…**.
 2. Enter package repository URL: `https://github.com/GeekingwithMauri/AdsEngine`
 3. Confirm the version and let Xcode resolve the package

### Swift Package Manager

If you want to use _AdsEngine_ in any other project that uses [SwiftPM](https://swift.org/package-manager/), add the package as a dependency in `Package.swift`:

```swift
dependencies: [
  .package(
    url: "https://github.com/GeekingwithMauri/AdsEngine",
    from: "0.1.0"
  ),
]
```

## Example of usage

### Banner usage

Within the desired place (usually a `ViewController`) where an ad is going to be shown, add the following:

```swift
import AdsEngine

class SomeViewController {
    private lazy var bannerContainer: UIView = {
        let container = UIView(frame: .zero)
        container.translatesAutoresizingMaskIntoConstraints = false

        return container
    }()

    private lazy var bannerAd: BannerProvider = {
        let banner = BannerProvider(identifier: "ad identifier")
        banner.initBannerToBeIncluded(in: bannerContainer)
        banner.adDelegate = self

        return banner
    }()

    override func viewDidLoad() {
    	super.viewDidLoad()
        ...
        bannerAd.loadAd(for: self)
    }
}

extension SomeViewController: AdInteractable {
    func adLoaded() {
        print("Banner loaded!")
    }

    func failedToPresent(dueTo error: Error) {
        print("Banner failed to init due to \(error.localizedDescription)")
    }
}
```

### Interstitial usage
_pending doc_

## Testing 
_pending doc_

## Current limitations
- For the time being, this only supports Google's AdsMob. 
- `GoogleService-Info` must be included in the main project
