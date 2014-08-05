workspace 'TMTProject'
xcodeproj 'TeXtended/TeXtended.xcodeproj'
xcodeproj 'TMTBibTexTools/TMTBibTexTools.xcodeproj'
xcodeproj 'TMTHelperCollection/TMTHelperCollection.xcodeproj'
xcodeproj 'MMTabBarView/MMTabBarView/MMTabBarView.xcodeproj'
xcodeproj 'TMTLatexTableFramework/TMTLatexTableFramework.xcodeproj'

platform :osx, '10.7'

target :TMTHelperCollection do
    xcodeproj 'TMTHelperCollection/TMTHelperCollection.xcodeproj'
	pod 'CocoaLumberjack', '>= 1.9.1'
end

target :TMTBibTexTools do
    xcodeproj 'TMTBibTexTools/TMTBibTexTools.xcodeproj'
	pod 'CocoaLumberjack', '>= 1.9.1'
	pod 'TMTHelperCollection', :path => './TMTHelperCollection'
end

#target :TMTLatexTableFramework do
#    xcodeproj 'TMTLatexTableFramework/TMTLatexTableFramework.xcodeproj'
#end

target :TeXtended do
    xcodeproj 'TeXtended/TeXtended.xcodeproj'
	pod 'CocoaLumberjack', '>= 1.9.1'
    pod 'DMInspectorPalette'
    pod 'OTMXAttribute'
    pod 'JSONKit-NoWarning'
	pod 'Sparkle'
	pod 'TMTHelperCollection', :path => './TMTHelperCollection'
	pod 'TMTBibTexTools', :path => './TMTBibTexTools'
	pod 'MMTabBarViewTMTFork', :path => './MMTabBarView'
end

target 'TeXtended Tests', :exclusive => true do
    xcodeproj 'TeXtended/TeXtended.xcodeproj'
    pod 'Kiwi'
end
