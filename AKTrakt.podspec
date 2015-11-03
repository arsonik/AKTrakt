#
# Be sure to run `pod lib lint AKTrakt.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "AKTrakt"
  s.version          = "0.1.4"
  s.summary          = "Swift Trakt.tv client."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
    A simple trakt.tv client written in swift.
                       DESC

  s.homepage         = "https://github.com/arsonik/AKTrakt"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Florian Morello" => "arsonik@me.com" }
  s.source           = { :git => "https://github.com/arsonik/AKTrakt.git", :tag => s.version.to_s }
  s.source           = { :git => "https://github.com/arsonik/AKTrakt.git", :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'

  s.requires_arc = true

  s.source_files = 'Pod/Classes/shared/**/*'
  s.ios.source_files = 'Pod/Classes/ios/**/*'
  s.tvos.source_files = 'Pod/Classes/tvos/**/*'

    s.tvos.resource_bundles = {
        'AKTraktTvOs' => [
            'Pod/Resources/tvos/**/*'
        ]
    }

  s.ios.frameworks = 'UIKit', 'Webkit'
  s.dependency 'Alamofire'
#  s.tvos.dependency 'QRCode'

end
