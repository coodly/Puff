Pod::Spec.new do |s|
  s.name = 'Puff'
  s.version = '0.4.0'
  s.license = 'Apache 2'
  s.summary = 'CloudKit wrapper'
  s.homepage = 'https://github.com/coodly/Puff'
  s.authors = { 'Jaanus Siim' => 'jaanus@coodly.com' }
  s.source = { :git => 'git@github.com:coodly/Puff.git', :tag => s.version }

  s.ios.deployment_target = '10.0'
  s.tvos.deployment_target = '10.0'
  s.osx.deployment_target = '10.11'

  s.requires_arc = true

  s.default_subspec = 'Core'

  s.subspec 'Core' do |core|
    core.source_files = 'Sources/Puff/*.swift'
  end
  
  s.subspec 'CoreData' do |cd|
    cd.source_files = "Sources/PuffCD/*.swift"
  end
end
