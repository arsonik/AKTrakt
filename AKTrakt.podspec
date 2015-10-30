Pod::Spec.new do |s|
  s.name = 'AKTrakt'
  s.version = '0.1'
  s.license = 'MIT'
  s.summary = 'Swift Trakt.tv client'
  s.authors = { 'Florian Morello' => 'arsonik+git@gmail.com' }
  s.source = { :git => 'https://github.com/arsonik/AKTrakt.git', :tag => s.version }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.tvos.deployment_target = '9.0'

  s.source_files = 'src/*.swift'

  s.requires_arc = true
end
