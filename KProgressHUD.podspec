Pod::Spec.new do |s|
    s.name                  = "KProgressHUD"
    s.version               = "1.0.3"
    s.summary               = "An iOS activity indicator view."
    s.description  = <<-EOS
                        KProgressHUD is a framework that rewrite the [MBProgressHUD](https://github.com/jdg/MBProgressHUD) in Swift.
                    EOS
    s.homepage              = "https://github.com/growup-together/KProgressHUD"
    s.license               = { :type => "MIT", :file => "LICENSE" }
    s.author                = "Kid17 iOS Team"
    s.platform              = :ios
    s.ios.deployment_target = '9.0'
    s.swift_version         = '5.0'
    s.source                = { :git => "https://github.com/growup-together/KProgressHUD.git",
    :tag => s.version.to_s }

    s.frameworks            = 'QuartzCore', 'CoreGraphics'
    s.source_files          = 'KProgressHUD/Classes/**/*.swift'

    s.dependency 'SnapKit', '~> 4.2.0'
end
