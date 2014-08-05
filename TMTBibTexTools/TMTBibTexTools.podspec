Pod::Spec.new do |s|
  s.name     = 'TMTBibTexTools'
  s.version  = '0.1.0'
  s.license  = 'MIT'
  s.summary  = "A pretty obscure library.
                You've probably never heard of it."
  s.homepage = 'http://textended.de'
  s.authors  = { 'Tobias Mende' =>
                 'tobias.mende@tobsolution.de' }
  s.source_files = 'TMTBibTexTools/**/*.{h,m}'
  s.requires_arc = true
  s.dependency 'CocoaLumberjack', '>= 1.9.1' 
end
