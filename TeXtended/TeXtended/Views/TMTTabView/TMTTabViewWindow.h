//
//  TMTTabViewWindow.h
//  TeXtended
//
//  Created by Max Bannach on 28.09.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TMTTabView, TMTTabViewItem;
@interface TMTTabViewWindow : NSWindowController {
    TMTTabViewItem* item1;
    TMTTabViewItem* item2;
    TMTTabViewItem* item3;
    TMTTabViewItem* item4;
    TMTTabViewItem* item5;
}


@property (strong) IBOutlet TMTTabView* tabView;


@end
