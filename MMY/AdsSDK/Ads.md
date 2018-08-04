# AdsManager
### Install
Before using module, you must install the following framework with cocoapods.
- Snapkit
- Firebase
- Firebase/Admob
- SwiftyJSON
- FBAudienceNetwork
- XCGLogger

### Usage
In each source file you want to use ads, add:
```Swift
import AdsManager
```

You need to declare adsManager 
```Swift
adsManager = AdsManager.shareInstance
```

Before loading ads in json file, declare provider you want to use
```Swift
AdsManager.sharedInstance.addProvider(provider: AdsGoogleProvider())
AdsManager.sharedInstance.addProvider(provider: AdsFacebookProvider())
```

Load all ads in json file with the method
```Swift
AdsManager.sharedInstance.loadAllAds(in: controller)
```
- controller: the controller you want to manage the ads

To show ads in view, you call the following method:
```Swift
showAds(customType: AdCustomType, normalFrameSize: CGSize? = nil, normalAdSize: CGSize? = nil, smartSize: AdsSmartSize = .smartPortrait, inView: UIView? = nil, inController: UIViewController? = nil)
```
- customType: Type of ad you want to identify the ad and define in enum CustomType
- normalFrameSize: The frame size of ad
- normalAdSize: The size of ad 
- smartSize: the size of ad with default value has already defined by Google (use for google admob)
- inView: The view display the ad
- inController: the controller manage the ad (use for interstitial ads)

You can see some default value next to parameters, you can use the method with these parameters or you can omit these paremeter when call the method, it will use the value you defined in ads.json file

### Define Ads in Enum
The following enum is the place you define your ads with your identifications. It stores in AdsEnum.swift file
```Swift
enum AdCustomType : String{
case adSmartTopView = "adSmartTopView"
case adSmartBottomView = "adSmartBottomView"
case adNativeView = "adNativeView"
case adInterstitial = "adInterstitial"

case adFBBannerView = "adFBBannerView"
case adFBNativeView = "adFBNativeView"
case adFBCustomNativeView = "adFBCustomNativeView"
case adFBInterstitialView = "adFBInterstitialView"
}
```
- Above is my ad cases, you need to declare your cases
### Define Ads Json File

To use an ad, you must define the ad in ads.json file. the struct of ad is define as follows:
```Json
{
"adCustomType": "adSmartTopView",
"adType": "smart",
"provider": "google",
"adSmartSize": "portrait",
"width": 300,
"height": 200,
"id": "ca-app-pub-3940256099942544/2562852117"
}
```
- adCustomType: The identification of ad you want to identify ads. It is define in AdCustomType enum
- adType: The type of ad. It is defined in AdType enum
- provider: The provider of ad (Google, Facebook)
- adSmartSize: The size of ad which has been already define by Google (only use for Google Ad)
- width, height: The custom size you want to modify the ad size
- id: The id of ad
