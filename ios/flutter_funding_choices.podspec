#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_funding_choices.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_funding_choices'
  s.version          = '0.1.1'
  s.summary          = 'The Flutter implementation of Funding Choices, a Google service that allows to request user consent for personalized ads in AdMob.'
  s.description      = <<-DESC
The Flutter implementation of Funding Choices, a Google service that allows to request user consent for personalized ads in AdMob.
                       DESC
  s.homepage         = 'https://pub.dev/packages/flutter_funding_choices'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Skyost' => 'me@skyost.eu' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'

  s.dependency 'GoogleUserMessagingPlatform', '~> 1.3.0'
  s.static_framework = true

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
