Pod::Spec.new do |s|
  s.name     = 'TMTLatexTable'
  s.version  = '0.1.0'
  s.license  = 'MIT'
  s.summary  = "A spreadsheet editor for latex tables"
  s.homepage = 'http://textended.de'
  s.authors  = { 'Tobias Mende' =>
                 'tobias.mende@tobsolution.de' }
  s.source_files = 'TMTLatexTableFramework/**/*.{h,m}'
  s.resources = 'TMTLatexTableFramework/**/*.{png,jpg,nib,xib}'
  s.requires_arc = true
  s.dependency 'CocoaLumberjack', '>= 1.9.1' 
  s.dependency 'TMTHelperCollection'
end
