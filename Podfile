workspace 'TMTProject'
xcodeproj 'TeXtended/TeXtended.xcodeproj'
xcodeproj 'DBLP Tool/DBLP Tool.xcodeproj'
xcodeproj 'TMTHelperCollection/TMTHelperCollection.xcodeproj'
xcodeproj 'MMTabBarView/MMTabBarView/MMTabBarView.xcodeproj'

platform :osx, '10.7'


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