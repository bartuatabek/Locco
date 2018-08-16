source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.3'
use_frameworks!
inhibit_all_warnings!

target 'Locco' do
    pod 'Alamofire'
    pod 'MessageKit'
    pod 'SwiftyJSON'
    pod 'GoogleSignIn'
    pod 'ReactiveCocoa'
    pod 'FBSDKLoginKit'
    pod 'Firebase/Auth'
    pod 'Firebase/Core'
    pod 'FirebaseStorage'
    pod 'PullUpController'
    pod 'Firebase/Firestore'
    pod 'Firebase/Messaging'
    pod 'MapKitGoogleStyler'
    pod 'IQKeyboardManagerSwift'
    pod 'ADCountryPicker', '~> 2.0.0'
    pod 'SwipeCellKit', :git => 'https://github.com/SwipeCellKit/SwipeCellKit.git', :branch => 'swift_4.2'
    post_install do |installer|
        installer.pods_project.targets.each do |target|
            if target.name == 'MessageKit'
                target.build_configurations.each do |config|
                    config.build_settings['SWIFT_VERSION'] = '4.0'
                end
            end
        end
    end
end

