#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint bgps_flutter_quuppa_driver.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'bgps_flutter_ios_quuppa_driver'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.vendored_frameworks = 'Frameworks/bgps_flutter_ios_quuppa_driver.xcframework'
  s.dependency 'Flutter'
  s.platform = :ios, '14.0'

  # Required iOS frameworks
  s.frameworks = 'CoreBluetooth', 'CoreLocation'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'bgps_flutter_quuppa_driver_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
