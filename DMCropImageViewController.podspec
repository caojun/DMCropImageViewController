Pod::Spec.new do |s|
  s.name         = "DMCropImageViewController"
  s.version      = “0.0.2”
  s.summary      = ""
  s.description  = ""
  s.homepage     = "https://github.com/caojun/DMCropImageViewController.git"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = { “Jun” => "caojengineer@126.com" }

  s.platform    = :ios
  s.platform    = :ios, "7.0"

  s.source       = { :git => "https://github.com/caojun/DMCropImageViewController.git", :tag => s.version.to_s }

  s.source_files  = 'DMCropImageViewController/*.{h,m}'
  s.exclude_files = ‘DMCropImageViewController/Exclude’
  s.resource      = 'DMCropImageViewController/*.{xib,json}'

  s.requires_arc = true

end
