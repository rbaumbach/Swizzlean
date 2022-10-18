Pod::Spec.new do |s|
  s.name                  = 'Swizzlean'
  s.version               = '1.1.0'
  s.summary               = 'A quick and lean way to swizzle methods for your Objective-C development needs.'
  s.homepage              = 'https://github.com/rbaumbach/Swizzlean'
  s.license               = { :type => 'MIT', :file => 'MIT-LICENSE.txt' }
  s.author                = { 'Ryan Baumbach' => 'github@ryan.codes' }
  s.source                = { :git => 'https://github.com/rbaumbach/Swizzlean.git', :tag => s.version.to_s }
  s.requires_arc          = true
  s.ios.deployment_target = '8.0'
  s.public_header_files   = 'Swizzlean/Source/Swizzlean.h'
  s.source_files          = 'Swizzlean/Source/*.{h,m}'
end
