Pod::Spec.new do |s|
  s.name             = 'bridgefy'
  s.version          = '0.0.1'
  s.summary          = 'Bridgefy native iOS SDK.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://bridgefy.me'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Bridgefy' => 'contact@bridgefy.me' }
  s.source           = { :git => 'https://github.com/bridgefy/sdk-ios.git', :tag => '1.2.4' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'
  s.dependency 'BridgefySDK'
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
