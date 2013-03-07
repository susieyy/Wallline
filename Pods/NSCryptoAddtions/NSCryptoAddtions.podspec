#
# Be sure to run `pod spec lint NSCryptoAddtions.podspec' to ensure this is a
# valid spec.
#
# Remove all comments before submitting the spec.
#
Pod::Spec.new do |s|
  s.name     = 'NSCryptoAddtions'
  s.version  = '1.0.1'
  s.license  = 'MIT'
  s.summary  = 'Category of NSString, NSData and UIImage for Crypto.'
  s.homepage = 'https://github.com/susieyy/NSCryptoAddtions'  

  # Specify the location from where the source should be retreived.
  #
  s.source   = { :git => 'https://github.com/susieyy/NSCryptoAddtions.git', :tag => 'v1.0.1' }

  s.description = 'Category of NSString, NSData and UIImage for Crypto.'

  # If this Pod runs only on iOS or OS X, then specify that with one of
  # these, or none if it runs on both platforms.
  #
  s.platform = :ios
  # s.platform = :osx

  # A list of file patterns which select the source files that should be
  # added to the Pods project. If the pattern is a directory then the
  # path will automatically have '*.{h,m,mm,c,cpp}' appended.
  #
  # Alternatively, you can use the FileList class for even more control
  # over the selected files.
  # (See http://rake.rubyforge.org/classes/Rake/FileList.html.)
  #
  s.source_files = '*.{h,m}'
  s.requires_arc = true

  #s.library = 'libgcrypt'
end
