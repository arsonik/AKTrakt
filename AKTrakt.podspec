Pod::Spec.new do |s|
  s.name             = "AKTrakt"
  s.version          = "0.3.0"
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

  s.requires_arc = true

  s.source_files = 'Source/Classes/shared/**/*'
  s.ios.source_files = 'Source/Classes/ios/**/*'
  s.tvos.source_files = 'Source/Classes/tvos/**/*'
  s.tvos.resources = 'Source/Resources/tvos/*.{xib,png}'

  s.ios.frameworks = 'UIKit', 'Webkit'
  s.dependency 'Alamofire', '~> 3.4.0'

end
