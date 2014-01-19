//
//  TemplateController.h
//  TeXtended
//
//  Created by Tobias Mende on 18.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Template;
@interface TemplateController : NSWindowController<NSTableViewDelegate,NSCollectionViewDelegate> {
    NSPopover *editPopover;
}

@property NSMutableArray *categories;
@property NSMutableArray *currentTemplates;
@property BOOL isSaving;
@property BOOL overrideAllowed;
@property (strong) IBOutlet NSArrayController *categoriesController;
@property (strong) IBOutlet NSCollectionView *currentTemplatesView;
@property (strong) IBOutlet NSWindow *sheet;
@property (strong) NSString *templateName;
@property (strong) NSString *templateDescription;
@property (strong) void (^saveHandler)(Template *template, BOOL success);
@property (strong) void (^loadHandler)(Template *template, BOOL success);

- (void)openSavePanelForWindow:(NSWindow *)window;
- (void)openLoadWindow;
- (IBAction)cancel:(id)sender;
- (IBAction)load:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)finallySave:(id)sender;
- (IBAction)cancelSave:(id)sender;
- (NSString *)currentCategoryPath;
- (IBAction)removeTemplate:(id)sender;
- (IBAction)editTemplate:(id)sender;
- (IBAction)saveEditTemplate:(id)sender;
- (BOOL)canSaveWithName;
- (BOOL)templateExists;
- (BOOL)canRemoveTemplate;
- (BOOL)canSaveEdit;
- (BOOL)canLoad;
@end
