//
//  TemplateController.h
//  TeXtended
//
//  Created by Tobias Mende on 18.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Template;
@interface TemplateController : NSWindowController<NSTableViewDelegate>

@property NSMutableArray *categories;
@property NSMutableArray *currentTemplates;
@property BOOL isSaving;
@property (strong) IBOutlet NSArrayController *categoriesController;
@property (strong) IBOutlet NSCollectionView *currentTemplatesView;
@property (strong) IBOutlet NSWindow *sheet;
@property (strong) NSString *templateName;
@property (strong) NSString *templateDescription;
@property (strong) void (^saveHandler)(Template *template, BOOL success);


- (void)openSavePanelForWindow:(NSWindow *)window;
- (IBAction)cancel:(id)sender;
- (IBAction)load:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)finallySave:(id)sender;
- (IBAction)cancelSave:(id)sender;
- (NSString *)currentCategoryPath;
- (BOOL)canSaveWithName;

@end
