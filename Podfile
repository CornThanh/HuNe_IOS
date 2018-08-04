# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'MMY' do

use_frameworks!

  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  # Pods for MMY

pod 'SnapKit', '3.2.0'
pod 'Firebase'
pod 'Firebase/AdMob'
pod 'Firebase/Core'
pod 'Firebase/Messaging'
pod 'Alamofire'
pod 'SwiftyJSON'
pod 'Kingfisher', '~> 3.13.1'
pod 'FacebookCore'
pod 'FacebookLogin'
pod 'FBAudienceNetwork'
pod 'FacebookShare', :git => 'https://github.com/1amageek/facebook-sdk-swift'
pod 'MJRefresh'
pod 'NVActivityIndicatorView'
pod 'XCGLogger', '~> 5.0.4'
pod 'MMDrawerController'
pod 'GoogleSignIn'
pod 'Localize-Swift'
pod 'GoogleMaps'
pod 'GooglePlaces'
pod 'Eureka', :git => 'https://github.com/xmartlabs/Eureka.git', :branch => 'Xcode9-Swift3_2'
pod 'IQKeyboardManagerSwift'
pod 'Fabric'
pod 'Crashlytics'
pod 'ChameleonFramework'
pod 'DropDown'
pod 'RSKImageCropper'
pod 'SDWebImage/WebP'

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.2'
            config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = 'NO'
        end
	end
end

