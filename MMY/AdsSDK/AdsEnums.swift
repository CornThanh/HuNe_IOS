//
//  AdEnum.swift
//  SwiftProject1
//
//  Created by Blue R&D on 2/8/17.
//  Copyright © 2017 Blue R&D. All rights reserved.
//

import UIKit

enum AdsSmartSize : String{
    case smartPortrait = "portrait"
    case smartLandscape = "landscape"
}

enum AdType : String{
    case normal = "normal"
    case smart = "smart"
    case native = "native"
    case customNative = "customNative"
    case interstitial = "interstitial"
}

enum AdCustomType : String{
    case adGGSmartTopView = "adGGSmartTopView"
    case adGGSmartBottomView = "adGGSmartBottomView"
    case adGGNormalView = "adGGNormalView"
    case adGGNativeView = "adGGNativeView"
    case adGGInterstitial = "adGGInterstitial"
    
    case adFBBannerView = "adFBBannerView"
    case adFBBigBannerView = "adFBBigBannerView"
    case adFBNativeView = "adFBNativeView"
    case adFBCustomNativeView = "adFBCustomNativeView"
    case adFBInterstitialView = "adFBInterstitialView"
}

enum AdsProviderType : String{
    case google = "google"
    case facebook = "facebook"
}
