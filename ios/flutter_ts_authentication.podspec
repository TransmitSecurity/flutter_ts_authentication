#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_ts_authentication.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_ts_authentication'
  s.version          = '0.0.5'
  s.summary          = 'A plugin for the Transmit Security Authentication SDK.'
  s.description      = <<-DESC
A Flutter plugin for the Transmit Security Authentication SDK.
                       DESC
  s.homepage         = 'https://github.com/TransmitSecurity/flutter_ts_authentication'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Transmit Security' => 'transmitsecurity.com' }
  s.source           = { :path => '.' }
  s.source_files = 'flutter_ts_authentication/Sources/flutter_ts_authentication/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '15.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'flutter_ts_authentication_privacy' => ['flutter_ts_authentication/Sources/flutter_ts_authentication/PrivacyInfo.xcprivacy']}
end
