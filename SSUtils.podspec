

Pod::Spec.new do |s|
  s.name         = "SSUtils"
  s.version      = "0.0.1"
  s.summary      = "swift develop utils"
  s.ios.deployment_target = '10.0'
  s.swift_versions = "5.0"
  s.homepage     = "https://github.com/namesubai/SSUtils.git"
  s.author             = { "subai" => "804663401@qq.com" }
  s.source       = { :git => "https://github.com/namesubai/SSUtils.git", :tag => "#{s.version}"}
  s.license      = "MIT"
  s.default_subspec = "Core"
  s.subspec "Core" do |ss|
    ss.source_files  = "Source/Core/**/*/*.swift"
#    ss.resource_bundles = {'Resources' => ['Source/Core/Resources/*.xcassets']}
    ss.resources = 'Source/Core/Resources/*.xcassets', 'Source/Core/Resources/**/*/*.strings'
    ss.dependency "Moya-ObjectMapper"
    ss.dependency "SnapKit"
    ss.dependency "SSAlertSwift"
    ss.dependency "SSPage-Swift"
    ss.dependency "RxCocoa"
    ss.dependency "RxSwift"
    ss.dependency "Kingfisher"
    ss.dependency "SwiftyJSON"
    ss.dependency "MJRefresh"
    ss.dependency "NSObject+Rx"
    ss.dependency "RxGesture"
    ss.dependency "RxOptional"
    ss.dependency "RxViewController"
    ss.dependency "YYCache"
    ss.dependency "YYText"
    ss.dependency "CocoaLumberjack/Swift" #, :configurations => ['Debug']
    ss.dependency "KeychainAccess"  # https://github.com/kishikawakatsumi/KeychainAccess
    ss.dependency "RxSwiftExt"
    ss.dependency "CryptoSwift"
    ss.framework  = "Foundation"
  end
  
end
