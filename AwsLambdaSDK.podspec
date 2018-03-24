Pod::Spec.new do |s|

  s.name         = "AwsLambdaSDK"
  s.version      = "0.1.0"
  s.summary      = "Swift library which enables you to invoke AWS Lambda programmatically"
  s.homepage     = "https://github.com/nikola-mladenovic/AwsSwiftLambdaSdk"
  s.license      = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.author       = { "Nikola Mladenovic" => "nikola@mladenovic.biz" }
  s.source       = { :git => "https://github.com/nikola-mladenovic/AwsSwiftLambdaSdk.git", :tag => s.version.to_s }
  s.source_files = 'Sources/AwsLambda/*.swift'
  s.swift_version = "4.0"
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0' }

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.2'

  s.dependency 'AwsSign', '~> 0.1'

end
