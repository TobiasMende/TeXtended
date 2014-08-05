workspace 'TMTProject'
xcodeproj 'TeXtended/TeXtended.xcodeproj'
xcodeproj 'TMTBibTexTools/TMTBibTexTools.xcodeproj'
xcodeproj 'TMTHelperCollection/TMTHelperCollection.xcodeproj'
xcodeproj 'MMTabBarView/MMTabBarView/MMTabBarView.xcodeproj'
xcodeproj 'TMTLatexTableFramework/TMTLatexTableFramework.xcodeproj'

platform :osx, '10.7'

target :TMTHelperCollection do
    xcodeproj 'TMTHelperCollection/TMTHelperCollection.xcodeproj'
	pod 'CocoaLumberjack'
end

target :TMTBibTexTools do
    xcodeproj 'TMTBibTexTools/TMTBibTexTools.xcodeproj'
	pod 'CocoaLumberjack'
end

target :TMTLatexTableFramework do
    xcodeproj 'TMTLatexTableFramework/TMTLatexTableFramework.xcodeproj'
	pod 'CocoaLumberjack'
end

target :TeXtended do
    xcodeproj 'TeXtended/TeXtended.xcodeproj'
    pod 'DMInspectorPalette'
    pod 'OTMXAttribute'
    pod 'JSONKit-NoWarning'
	pod 'CocoaLumberjack'
	pod 'Sparkle'
end

target 'TeXtended Tests', :exclusive => true do
    xcodeproj 'TeXtended/TeXtended.xcodeproj'
    pod 'Kiwi'
end
