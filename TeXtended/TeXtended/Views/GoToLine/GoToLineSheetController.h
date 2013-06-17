//
//  GoToLineSheetController.h
//  TeXtended
//
//  Created by Tobias Mende on 17.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GoToLineSheetController : NSWindowController
- (IBAction)cancelSheet:(id)sender;
- (IBAction)goToLine:(id)sender;
@property NSNumber *line;
@property NSNumber *max;
@end
