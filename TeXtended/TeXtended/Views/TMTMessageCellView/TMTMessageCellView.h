//
//  TMTMessageCellView.h
//  TeXtended
//
//  Created by Tobias Mende on 23.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TrackingMessage, DocumentModel;

@interface TMTMessageCellView : NSTableCellView

    - (NSImage *)image;

    - (NSString *)lineString;

    - (TrackingMessage *)message;

    @property (strong, nonatomic) DocumentModel *model;

    @property BOOL isExternal;
@end
