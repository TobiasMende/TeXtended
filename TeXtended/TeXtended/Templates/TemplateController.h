//
//  TemplateController.h
//  TeXtended
//
//  Created by Max Bannach on 14.09.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NewTemplateController;
@interface TemplateController : NSObject <NSTableViewDataSource, NSTableViewDelegate> {
 
    IBOutlet NSTableView* table;
    NSMutableArray* templates;
    NewTemplateController* newTemplateController;
    
}

/** the sheet that displays possible templates */
@property (assign) IBOutlet NSWindow* sheet;

/** Open a sheet with a template overview in the given window */
- (void)openSheetIn:(NSWindow*)window;

/** Close the sheet */
- (IBAction)closeSheet:(id)sender;

/** Load the selected template to the pasteboard */
- (IBAction)loadTemplate:(id)sender;

/** Save the tempalte from the pasteboard to the selected file */
- (IBAction)saveTemplate:(id)sender;

/** open the new template sheet */
- (IBAction)addTemplate:(id)sender;

/** Add a new template with the given name */
- (void) addTemplateWithName:(NSString*) fileName andContent:(BOOL) addContent;

/** Remove the selected template from the template folder */
- (IBAction)removeTemplate:(id)sender;

@end
