workspace 'TMTProject'
xcodeproj 'TeXtended/TeXtended.xcodeproj'
xcodeproj 'DBLP Tool/DBLP Tool.xcodeproj'
xcodeproj 'TMTHelperCollection/TMTHelperCollection.xcodeproj'
xcodeproj 'MMTabBarView/MMTabBarView/MMTabBarView.xcodeproj'
xcodeproj 'TMTLatexTableFramework/TMTLatexTableFramework.xcodeproj'

platform :osx, '10.7'

target :TMTLatexTableFramework do
    xcodeproj 'TMTLatexTableFramework/TMTLatexTableFramework.xcodeproj'
end

target :TMTHelperCollection do
    xcodeproj 'TMTHelperCollection/TMTHelperCollection.xcodeproj'
    pod 'CocoaLumberjack'
end

target :BibTexToolsFramework do
    xcodeproj 'DBLP Tool/DBLP Tool.xcodeproj'
end

target :TeXtended do
    xcodeproj 'TeXtended/TeXtended.xcodeproj'
    pod 'DMInspectorPalette'
    pod 'OTMXAttribute'
    pod 'JSONKit-NoWarning'
end

target 'TeXtended Tests', :exclusive => true do
    xcodeproj 'TeXtended/TeXtended.xcodeproj'
    pod 'Kiwi'
end
