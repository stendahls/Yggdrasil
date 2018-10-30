#
# Be sure to run `pod lib lint Yggdrasil.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Yggdrasil'
  s.version          = '0.1.3'
  s.summary          = 'An async/await based network library for Swift.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  Yggdrasil is a network library which allows to create and execute async/await based network requests. The focus is on easy and simple usage to avoid too much code overhead. Yggdrasil is protocol based with some additional structs and classes for convenient usage.
                       DESC

  s.homepage         = 'https://github.com/stendahls/Yggdrasil'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Thomas Sempf' => 'thomas.sempf@stendahls.se' }  
  s.source           = { :git => 'https://github.com/stendahls/Yggdrasil.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/tsempf'

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = "10.12"
  s.tvos.deployment_target = "10.0"
  s.watchos.deployment_target = '3.0'

  s.swift_version = '4.2'
  
  s.source_files = 'Yggdrasil/Classes/**/*'
  
  s.requires_arc = true  
  s.dependency 'Alamofire', '~> 4.7'
  s.dependency 'Taskig', '~> 0.2'
  
end
