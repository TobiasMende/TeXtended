//
//  GoToLineSheetController.h
//  TeXtended
//
//  Created by Tobias Mende on 17.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 Controller for the go to line sheet panel
 
 **Author:** Tobias Mende
 
 */
@interface GoToLineSheetController : NSWindowController

/** Property for the current line */
    @property NSNumber *line;

/** Property for the maximum number of lines */
    @property NSNumber *max;

/** Method for aborting the sheet 
 @param sender the sender
 */
    - (IBAction)cancelSheet:(id)sender;

/** Method for starting the go to line action 
 @param sender the sender
 */
    - (IBAction)goToLine:(id)sender;
@end
