#
# Be sure to run `pod lib lint Birch.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name = 'Birch'
  s.version = '1.4.0'
  s.summary = 'Remote logger for the Birch platform.'
  s.homepage = 'https://github.com/gruffins/birch-swift'
  s.license = { type: 'MIT', file: 'LICENSE' }
  s.author = { 'Ryan Fung' => 'ryan@ryanfung.com' }
  s.source = { git: 'https://github.com/gruffins/birch-swift.git', tag: s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.tvos.deployment_target = '11.0'
  s.osx.deployment_target = '10.13'
  s.swift_version = '5.0'
  s.source_files = 'Sources/Birch/Classes/**/*'

  s.test_spec 'Tests' do |ts|
    ts.source_files = 'Tests/**/*.swift'
    ts.dependency 'Quick'
    ts.dependency 'Nimble'
  end
end
