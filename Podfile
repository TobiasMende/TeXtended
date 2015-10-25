workspace 'TMTProject'
xcodeproj 'TeXtended/TeXtended.xcodeproj'
xcodeproj 'TMTBibTexTools/TMTBibTexTools.xcodeproj'
xcodeproj 'TMTHelperCollection/TMTHelperCollection.xcodeproj'
xcodeproj 'MMTabBarView/MMTabBarView/MMTabBarView.xcodeproj'
xcodeproj 'TMTLatexTableFramework/TMTLatexTableFramework.xcodeproj'

platform :osx, '10.9'

target :TMTHelperCollection do
    xcodeproj 'TMTHelperCollection/TMTHelperCollection.xcodeproj'
	pod 'CocoaLumberjack'
end

target :TMTBibTexTools do
    xcodeproj 'TMTBibTexTools/TMTBibTexTools.xcodeproj'
	pod 'CocoaLumberjack'
	pod 'TMTHelperCollection', :path => './TMTHelperCollection'
end
target :DBLPTool do
    xcodeproj 'TMTBibTexTools/TMTBibTexTools.xcodeproj'
  pod 'TMTBibTexTools', :path => './TMTBibTexTools'
	pod 'CocoaLumberjack'
	pod 'TMTHelperCollection', :path => './TMTHelperCollection'
end


target :TMTLatexTableExample do
    xcodeproj 'TMTLatexTableFramework/TMTLatexTableFramework.xcodeproj'
    pod 'TMTLatexTable', :path => './TMTLatexTableFramework'
end

target :TMTLatexTableFramework do
    xcodeproj 'TMTLatexTableFramework/TMTLatexTableFramework.xcodeproj'
    pod 'CocoaLumberjack'
	pod 'TMTHelperCollection', :path => './TMTHelperCollection'
end

target :TeXtended do
    xcodeproj 'TeXtended/TeXtended.xcodeproj'
	pod 'CocoaLumberjack'
    pod 'DMInspectorPalette', '0.0.1'
    pod 'OTMXAttribute', '0.0.3'
    pod 'JSONKit-NoWarning', '1.2'
	pod 'Sparkle'
	pod 'TMTHelperCollection', :path => './TMTHelperCollection'
	pod 'TMTBibTexTools', :path => './TMTBibTexTools'
	pod 'MMTabBarViewTMTFork', :path => './MMTabBarView'
end

target 'TeXtended Tests', :exclusive => true do
    xcodeproj 'TeXtended/TeXtended.xcodeproj'
    pod 'Kiwi'
end
