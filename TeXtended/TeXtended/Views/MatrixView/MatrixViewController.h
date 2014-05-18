//
//  MatrixViewController.h
//  TeXtended
//
//  Created by Tobias Hecht on 15.10.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class EnvironmentCompletion;

@interface MatrixViewController : NSWindowController

    @property NSInteger rows;

    @property NSInteger columns;

    @property NSString *type;

    @property BOOL alignment;

    @property (readonly) NSInteger minimumTableSize;

    @property IBOutlet NSButton *OKButton;

/** Method for aborting the sheet
 @param sender the sender
 */
    - (IBAction)cancelSheet:(id)sender;

/** Method for starting the matrix template action
 @param sender the sender
 */
    - (IBAction)OKSheet:(id)sender;

    - (EnvironmentCompletion *)matrixCompletion;

@end
