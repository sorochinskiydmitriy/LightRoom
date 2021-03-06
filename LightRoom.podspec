
Pod::Spec.new do |s|
  s.name         = "LightRoom"
  s.version      = "0.10.4"
  s.summary      = "CoreImage Library"
  s.description  = "Easy Chaining ImageFilter with CoreImage."

  s.homepage     = "https://github.com/muukii/LightRoom"
  s.license      = "MIT"
  s.author             = { "muukii" => "m@muukii.me" }
  s.platform     = :ios
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/sorochinskiydmitriy/LightRoom.git", :tag => s.version.to_s }
  s.source_files  = "LightRoom/Classes/**/*.swift"
  s.exclude_files = "Classes/Exclude"
  s.frameworks  = "Foundation"
  s.swift_version = "4.2"
end
