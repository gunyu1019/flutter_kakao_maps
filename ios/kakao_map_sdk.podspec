#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_kakao_map.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'kakao_map_sdk'
  s.version          = '1.1.4'
  s.summary          = 'An unoffical kakao maps plugin.'
  s.description      = <<-DESC
An unoffical kakao maps plugin.
                       DESC
  s.homepage         = 'http://github.com/gunyu1019/flutter_kakao_maps'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Developer Space' => 'gunyu1019@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'KakaoMapsSDK', '2.12.5'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'flutter_kakao_map_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
