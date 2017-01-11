#platform :ios, '10.0'

target 'motoRoutes' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

# Pods for motoRoutes
pod 'Mapbox-iOS-SDK', '~> 3.3.7'
pod 'pop', '~> 1.0'
pod 'RealmSwift'
pod 'Fabric'
pod 'Crashlytics'
pod 'Alamofire', '~> 4.0'
pod 'AlamofireImage', '~> 3.1'
pod 'Firebase/Core'
pod 'Firebase/Auth'
pod 'Firebase/Database'
pod 'Firebase/Storage'
pod 'FBSDKLoginKit'
pod 'SwiftKeychainWrapper'
pod 'SwiftyJSON'

target 'motoRoutesTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0' # or '3.0'
    end
  end
end
