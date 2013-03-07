#
# Be sure to run `pod spec lint NSCryptoAddtions.podspec' to ensure this is a
# valid spec.
#
# Remove all comments before submitting the spec.
#
Pod::Spec.new do |s|
  s.name     = 'SSKeychainItemWrapper'
  s.version  = '1.0.2'
  s.license  = 'MIT'
  s.summary  = 'Objective-C wrapper for accessing a single keychain item.'
  s.homepage = 'https://github.com/susieyy/SSKeychainItemWrapper'
  s.source   = { :git => 'https://github.com/susieyy/SSKeychainItemWrapper.git', :tag => 'v1.0.2' }

  s.description = 'Objective-C wrapper for accessing a single keychain item.'

  # If this Pod runs only on iOS or OS X, then specify that with one of
  # these, or none if it runs on both platforms.
  #
  s.platform = :ios

  # A list of file patterns which select the source files that should be
  # added to the Pods project. If the pattern is a directory then the
  # path will automatically have '*.{h,m,mm,c,cpp}' appended.
  #
  # Alternatively, you can use the FileList class for even more control
  # over the selected files.
  # (See http://rake.rubyforge.org/classes/Rake/FileList.html.)
  #
  s.source_files = '*.{h,m}'
  s.requires_arc = false

  #s.library = 'Security'
end
