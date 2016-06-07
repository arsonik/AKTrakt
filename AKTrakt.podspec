Pod::Spec.new do |s|
  s.name             = "AKTrakt"
  s.version          = "1.0.1"
  s.summary          = "Swift Trakt.tv client."

  s.description      = <<-DESC
    A simple Trakt.tv client written in swift.
                       DESC

  s.homepage         = "https://github.com/arsonik/AKTrakt"
  s.screenshots     = "https://raw.githubusercontent.com/arsonik/AKTrakt/master/Screenshots/TVmovies.png", "https://raw.githubusercontent.com/arsonik/AKTrakt/master/Screenshots/iOSmovies.png"
  s.license          = 'MIT'
  s.authors           = { "Florian Morello" => "arsonik@me.com" }
  s.source           = { :git => "https://github.com/arsonik/AKTrakt.git", :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'

  s.source_files = 'Source/shared/**/*.swift'
  s.ios.source_files = 'Source/ios/**/*.swift'
  s.tvos.source_files = 'Source/tvos/**/*.swift'
  s.tvos.resources = 'Source/tvos/*.{xib,png}'

  s.ios.frameworks = 'UIKit', 'Webkit'
  s.dependency 'Alamofire', '~> 3.4.0'

end
