//
//  TMTTabView.h
//  TeXtended
//
//  Created by Tobias Mende on 22.09.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NSTabViewItem;
@interface TMTTabView : NSTabView {
    NSPoint mouse;
}

@property (weak) NSTabViewItem* draggedItem;

@end
