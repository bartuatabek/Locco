source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.3'
use_frameworks!
inhibit_all_warnings!

target 'Locco' do
    pod 'Firebase/Auth'
    pod 'Firebase/Core'
    pod 'FirebaseStorage'
    pod 'GoogleSignIn'
    pod 'FBSDKLoginKit'
    pod 'Alamofire'
    pod 'SwiftyJSON'
    pod 'ReactiveCocoa'
    pod 'KeychainAccess'
    pod 'PullUpController'
    pod 'MapKitGoogleStyler'
    pod 'IQKeyboardManagerSwift'
    pod 'ADCountryPicker', '~> 2.0.0'
    pod 'SwipeCellKit', :git => 'https://github.com/SwipeCellKit/SwipeCellKit.git', :branch => 'swift_4.2'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == '<insert target name of your pod here>'
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '3.2'
            end
        end
    end
end
