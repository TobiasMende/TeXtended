//
//  PreviewView.h
//  TeXtended
//
//  Created by Tobias Mende on 18.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Quartz/Quartz.h>

@interface TMTQuickLookView : QLPreviewView

    @property (strong) void (^mouseDownHandler)(NSEvent *theEvent);

@end
