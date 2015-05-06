Pod::Spec.new do |s|
  s.name             = "ApplicationInsights-Source"
  s.version          = "1.0-beta.2"
  s.summary          = "Microsoft Application Insights SDK for iOS"
  s.description      = <<-DESC
	                   Application Insights is a service that allows developers to keep their applications available, performant, and successful. 
	                   This SDK will allow you to send telemetry of various kinds (event, trace, exception, etc.) and useful crash reports to the Application Insights service where they can be visualized in the Azure Portal.
	                   DESC
  s.homepage         = "https://github.com/Microsoft/ApplicationInsights-iOS/"
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { "Microsoft" => "appinsights-ios@microsoft.com" }

  s.source           = { :git => "https://github.com/Microsoft/ApplicationInsights-iOS.git", :tag => "v#{s.version}" }

  s.platform     = :ios, '6.0'
  s.requires_arc = true
  s.frameworks   = 'CFNetwork', 'Foundation', 'Security', 'SystemConfiguration', 'UIKit'
  s.libraries    = 'z'
  s.weak_frameworks = 'CoreTelephony'

  s.xcconfig                = { 'GCC_PREPROCESSOR_DEFINITIONS' => %{$(inherited) MSAI_VERSION="@\\"#{s.version}\\"" MSAI_C_VERSION="\\"#{s.version}\\"" MSAI_BUILD="@\\"2\\"" MSAI_C_BUILD="\\"2\\""} }
  s.source_files            = 'Classes'
  s.private_header_files    = 'Classes/*Private.h'
  s.vendored_frameworks     = 'Vendor/CrashReporter.framework'
  s.preserve_paths          = 'Resources', 'Support' 
end