//
//  ExportCompileWindowController.h
//  TeXtended
//
//  Created by Max Bannach on 09.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class DocumentController;
@interface ExportCompileWindowController : NSWindowController

@property (weak) DocumentController* controller;
-(id)initWithDocumentController:(DocumentController*) controller;
- (IBAction)export:(id)sender;

@end
