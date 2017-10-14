
Pod::Spec.new do |s|

  s.name         = "OneDriveSDK"
  s.version      = "1.3.0"
  s.summary      = "OneDrive iOS SDK"

  s.description  = <<-DESC
                    Integrate the OneDrive API into your iOS App!
                   DESC

  s.homepage     = "https://dev.onedrive.com"



  s.license      = { :type => "MIT", :file => "LICENSE.txt" }


  s.author        = { "onedriveapi " => "onedrivesdkowners@microsoft.com" }
  s.social_media_url = "http://twitter.com/onedrivedev"

  s.platform     = :ios, "7.0"

  s.source       = { :git => "https://github.com/OneDrive/onedrive-sdk-ios.git",
                     :tag => "#{s.version}"}

  s.source_files = "OneDriveSDK/OneDriveSDK/OneDriveSDK.h"
  s.public_header_files = "OneDriveSDK/OneDriveSDK/OneDriveSDK.h"

  s.exclude_files = "Examples/*","OneDriveSDK/Test/*"


  s.subspec "Common" do |odp|
    odp.source_files = "OneDriveSDK/Common/*.{h,m}"
    odp.public_header_files = "OneDriveSDK/Common/*.h"
  end

  s.subspec "Implementations" do |usm|
    usm.dependency 'OneDriveSDK/Common'
    usm.source_files = "OneDriveSDK/OneDriveSDK/ODURLSessionManager/*{h,m}", "OneDriveSDK/OneDriveSDK/*{h,m}"
    usm.public_header_files = "OneDriveSDK/OneDriveSDK/**/*.h"
    usm.exclude_files = "OneDriveSDK/OneDriveSDK/OneDriveSDK.h"
  end


  s.subspec "Auth" do |oda|
    oda.dependency 'ADAL', '~> 1.2'
    oda.dependency 'Base32', '~> 1.1'
    oda.dependency 'OneDriveSDK/Common'

    oda.source_files = "OneDriveSDK/Auth/*.{h,m}", "OneDriveSDK/Accounts/*.{h,m}"
    oda.public_header_files = "OneDriveSDK/Auth/*.h", "OneDriveSDK/Accounts/*.h"

  end

  s.subspec "OneDriveCoreSDK" do |core|
    core.dependency 'OneDriveSDK/Common'

    core.source_files = "OneDriveSDK/OneDriveCoreSDK/**/*.{h,m}"
    core.public_header_files = "OneDriveSDK/OneDriveCoreSDK/**/*.h"

  end

  s.subspec "Extensions" do |ext|
    ext.dependency 'OneDriveSDK/OneDriveCoreSDK'
    ext.dependency 'OneDriveSDK/Implementations'
    ext.dependency 'OneDriveSDK/Auth'

    ext.source_files = "OneDriveSDK/Extensions/*.{h,m}"
    ext.public_header_files = "OneDriveSDK/Extensions/*.h"

  end


end
