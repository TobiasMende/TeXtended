//
//  DocumentSelectionAccessoryController.h
//  TeXtended
//
//  Created by Tobias Mende on 09.10.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DocumentSelectionAccessoryController : NSViewController <NSPrintPanelAccessorizing>
@property (strong) IBOutlet NSPopUpButton *documentSelector;
@property (strong) IBOutlet NSPopUpButton *typeSelector;

@end
