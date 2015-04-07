Pod::Spec.new do |s|
  s.name             = "ApplicationInsights"
  s.version          = "1.0-alpha.3"
  s.summary          = "Microsoft Application Insights SDK for iOS"
  s.description      = <<-DESC
                       Application Insights is a service that allows developers to keep their applications available, performant, and successful. 
                       This SDK will allow you to send telemetry of various kinds (event, trace, exception, etc.) and useful crash reports to the Application Insights service where they can be visualized in the Azure Portal.
                       DESC
  s.homepage         = "https://github.com/Microsoft/AppInsights-iOS/"
  s.license          = { :type => 'MIT', :file => 'AppInsights/LICENSE' }
  s.author           = { "Microsoft" => "appinsights-ios@microsoft.com" }

  s.source           = { :http => "https://github.com/Microsoft/AppInsights-iOS/releases/download/v#{s.version}/AppInsights-#{s.version}.zip" }

  s.platform        = :ios, '6.0'
  s.requires_arc    = true

  s.frameworks      = 'UIKit', 'Foundation', 'SystemConfiguration', 'Security'
  s.weak_framework  = 'CoreTelephony'

  s.ios.vendored_frameworks = 'AppInsights/AppInsights.framework'
  s.preserve_path   = 'AppInsights/README.md'
end
