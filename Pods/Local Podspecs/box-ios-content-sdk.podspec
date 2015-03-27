Pod::Spec.new do |s|

# Root specification

s.name                  = "box-ios-content-sdk"
s.version               = "1.0.0"
s.summary               = "iOS SDK for the Box V2 API."
s.homepage              = "https://gitenterprise.inside-box.net/Mobile/box-ios-content-sdk"
s.license               = { :type => "MIT", :file => "LICENSE" }
s.author                = "Box"
s.source                = { :git => "https://gitenterprise.inside-box.net/Mobile/box-ios-content-sdk", :tag => "v#{s.version}" }

# Platform

s.ios.deployment_target = "7.0"

# File patterns

s.ios.source_files        = "BoxContentSDK/BoxContentSDK/*.{h,m}", "BoxContentSDK/BoxContentSDK/**/*.{h,m}"
s.ios.exclude_files       = "BoxContentSDK/BoxContentSDK/External/ISO8601DateFormatter/BOXISO8601DateFormatter.{h,m}",
"BoxContentSDK/BoxContentSDK/External/KeychainItemWrapper/BOXKeychainItemWrapper.{h,m}"
s.ios.public_header_files = "BoxContentSDK/BoxContentSDK/*.h", "BoxContentSDK/BoxContentSDK/**/*.h"
s.resource_bundle = {
  'BoxContentSDKResources' => [
     'BoxContentSDK/BoxContentSDKResources/Assets/*.*',
     'BoxContentSDK/BoxContentSDKResources/Icons/*.*',
     'BoxContentSDK/BoxContentSDKResources/*.lproj'
  ]
}

# Build settings

s.ios.frameworks        = "Security", "QuartzCore", "AssetsLibrary"
s.requires_arc          = true
s.xcconfig              = { "OTHER_LDFLAGS" => "-ObjC -all_load" }
s.ios.header_dir        = "BoxContentSDK"

# Subspecs

s.subspec "logger" do |sp|
sp.source_files              = "BoxContentSDK/BoxContentSDK/BOXLog.h"
end

s.subspec "no-arc" do |sp|
sp.dependency                  "box-ios-content-sdk/logger"
sp.source_files              = "BoxContentSDK/BoxContentSDK/External/ISO8601DateFormatter/BOXISO8601DateFormatter.{h,m}",
"BoxContentSDK/BoxContentSDK/External/KeychainItemWrapper/BOXKeychainItemWrapper.{h,m}"
sp.requires_arc              = false
end

end
