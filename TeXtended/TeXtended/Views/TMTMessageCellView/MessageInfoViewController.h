//
//  MessageInfoViewController.h
//  TeXtended
//
//  Created by Tobias Mende on 30.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class TrackingMessage,Compilable;
@interface MessageInfoViewController : NSViewController {
    NSNumber *isExternalCache;
}

@property TrackingMessage *message;
@property (nonatomic) Compilable *model;

- (BOOL)isExternal;
- (NSImage *)image;
@end
