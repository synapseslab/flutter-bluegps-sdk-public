#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_bluegps_sdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_bluegps_sdk'
  s.version          = '0.0.1'
  s.summary          = 'BlueGPS SDK for Flutter Applications'
  s.description      = <<-DESC
A Flutter plugin for integrating BlueGPS indoor positioning system in iOS and Android applications.
                       DESC
  s.homepage         = 'https://github.com/synapseslab/flutter-bluegps-sdk'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Synapses Lab' => 'info@synapseslab.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
