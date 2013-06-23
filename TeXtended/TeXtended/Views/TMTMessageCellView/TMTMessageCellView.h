//
//  TMTMessageCellView.h
//  TeXtended
//
//  Created by Tobias Mende on 23.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TrackingMessage;
@interface TMTMessageCellView : NSTableCellView
- (NSImage *)image;
- (NSString *)lineString;
- (TrackingMessage*) message;
@end
