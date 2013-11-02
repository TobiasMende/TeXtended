//
//  DemoFakeModel.h
//  TeXtended
//
//  Created by Max Bannach on 26.10.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <MMTabBarView/MMTabBarItem.h>

@interface TMTTabViewItem : NSObject <MMTabBarItem> {
}

@property (copy)   NSString  *title;
@property (retain) NSImage   *largeImage;
@property (retain) NSImage   *icon;
@property (retain) NSString  *iconName;
@property (assign) BOOL       isProcessing;
@property (assign) NSInteger  objectCount;
@property (retain) NSColor   *objectCountColor;
@property (assign) BOOL       showObjectCount;
@property (assign) BOOL       isEdited;
@property (assign) BOOL       hasCloseButton;
@property (assign) NSView    *view;

// designated initializer
- (id)init;

@end
