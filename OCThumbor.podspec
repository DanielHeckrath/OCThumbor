#
# Be sure to run `pod spec lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about the attributes see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = "OCThumbor"
  s.version          = "0.1.0"
  s.summary          = "A short description of OCThumbor."
  s.description      = <<-DESC
                       An optional longer description of OCThumbor

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/DanielHeckrath/OCThumbor.git"
  s.license          = 'MIT'
  s.author           = { "Daniel Heckrath" => "daniel@codeserv.de" }
  s.source           = { :git => "https://github.com/DanielHeckrath/OCThumbor.git", :tag => '#{s.version}' }
  s.social_media_url = 'https://twitter.com/tchackie'

  s.requires_arc = true

  s.source_files = 'OCThumbor'

  s.dependency 'CocoaSecurity', '~> 1.2'
end
