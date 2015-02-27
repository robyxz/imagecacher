#
# Be sure to run `pod lib lint ImageCacher.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "ImageCacher"
  s.version          = "0.1.6"
  s.summary          = "ImageCacher helps you to manage image caching."
  s.description      = <<-DESC
                        The image caching is asynchronous and based on blocks and GCD. The persistent storage is based on CoreData, fetches are executed in background, last accessed images are stored into a memory buffer.
                       DESC
  s.homepage         = "https://github.com/robyxz/ImageCacher"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Roberto Sartori" => "roberto@rawfish.it" }
  s.source           = { :git => "https://github.com/robyxz/ImageCacher.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resource_bundles = {'ImageCacher' => ['Pod/Assets/**'] }

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit', 'MapKit', 'AVFoundation'
  # s.dependency 'AFNetworking', '~> 2.3'
end
