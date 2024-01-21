# GrandArt

![Github](https://img.shields.io/badge/macOS-12%2B-brightgreen)
[![macos-sonoma-14](https://img.shields.io/badge/macos-sonoma-blue.svg)](https://www.apple.com/macos/sonoma)
[![macos-Ventura-13](https://img.shields.io/badge/macos-ventura-blue.svg)](https://www.apple.com/macos/ventura)
[![macos-Monterey-12](https://img.shields.io/badge/macos-monterey-brightgreen.svg)](https://www.apple.com/macos/monterey)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

[![swift-version](https://img.shields.io/badge/swift-5.7-brightgreen.svg)](https://github.com/apple/swift)
[![swiftui-version](https://img.shields.io/badge/swiftui-3-brightgreen)](https://developer.apple.com/documentation/swiftui)
[![xcode-version](https://img.shields.io/badge/xcode-15-blue)](https://developer.apple.com/xcode/)
[![xcode-version](https://img.shields.io/badge/xcode-14-brightgreen)](https://developer.apple.com/xcode/)

SwiftUI macOS app to create custom art using variations of the Mandelbrot set.

Go to [Sources/GrandArt/Utilities/ArtInputs.swift](Sources/GrandArt/Utilities/ArtInputs.swift)

And specify the real and imaginary part of the exponent.

- At 2.0 + 0i, you have MandArt (with 2, 4, 8 branches)

- At 3.0 + 0i, you have something similar but odd (5, 7, 15 branches) 

The real part of the exponent will influence the "spreading" of the set, while the imaginary part will introduce a "rotation" or "twist."

![GrandArt - different exponents](Resources/GrandArtDay1.JPG)

- Applied Physics Engineering
- [Bruce Johnson](https://github.com/bruceranger)
- [App Store Connect](https://appstoreconnect.apple.com)
- [Care and Feeding of GrandArt](CARE_AND_FEEDING.md)
