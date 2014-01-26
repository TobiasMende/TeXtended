//
//  ExtendedTableView.h
//  TeXtended
//
//  Created by Tobias Mende on 12.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 This class provides an extension of the default NSTableView by extending the actions which can be send by instances of this class. All actions set in this class where executed by the NSTableViewDelegate of this view.
 
 **Author:** Tobias Mende
 
 */
@interface TMTTableView : NSTableView

/** Property containing a selector performed when the user presses enter on this view */
@property SEL enterAction;
@property SEL singleClickAction;
@property BOOL opaque;
@end
