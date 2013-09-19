//
//  NewTemplateController.h
//  TeXtended
//
//  Created by Max Bannach on 16.09.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TemplateController;
@interface NewTemplateController : NSObject

/** the shown sheet */
@property (strong) NSWindow* IBOutlet sheet;

/** the calling template controller */
@property (weak) TemplateController* tempalteController;

/** textfield with the templatename */
@property (weak) IBOutlet NSTextField *templateName;

/** create with content or empty? */
@property (weak) IBOutlet NSButtonCell *createWithContent;

- (id)initWithTemplateController:(TemplateController*) tempalteController;

/** Open a sheet with a template overview in the given window */
- (void)openSheetIn:(NSWindow*)window;

/** Close the sheet */
- (IBAction)closeSheet:(id)sender;

/** Add a template with the given name */
- (IBAction)addTemplate:(id)sender;

@end
