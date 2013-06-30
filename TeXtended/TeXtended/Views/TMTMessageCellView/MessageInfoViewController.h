//
//  MessageInfoViewController.h
//  TeXtended
//
//  Created by Tobias Mende on 30.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class TrackingMessage,DocumentModel;
@interface MessageInfoViewController : NSViewController

@property TrackingMessage *message;
@property DocumentModel *model;

- (BOOL)isExternal;
- (NSImage *)image;
@end
