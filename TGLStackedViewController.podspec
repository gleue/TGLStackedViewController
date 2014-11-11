Pod::Spec.new do |s|
  s.name     = 'TGLStackedViewController'
  s.version  = '1.0.3'
  s.license  = 'MIT'
  s.summary  = 'A stacked view layout with gesture-based reordering using a UICollectionView -- inspired by Passbook and Reminders apps.'
  s.homepage = 'https://github.com/gleue/TGLStackedViewController'
  s.authors  = { 'Tim Gleue' => 'tim@gleue-interactive.com' }
  s.source   = { :git => 'https://github.com/gleue/TGLStackedViewController.git', :tag => '1.0.3' }
  s.source_files = 'TGLStackedViewController'

  s.requires_arc = true
  s.platform = :ios, '6.0'
end
