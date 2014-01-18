//
//  TemplateController.m
//  TeXtended
//
//  Created by Tobias Mende on 18.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "TemplateController.h"
#import "Constants.h"
#import "ApplicationController.h"
#import "Template.h"
#import "NSFileManager+TMTExtension.h"
#import <TMTHelperCollection/TMTLog.h>
#import "TemplatePlaceholderController.h"

@interface TemplateController ()
- (void)loadCategories;
- (void)loadTemplatesFromCategory:(NSString *)category;
- (NSString*)templateDirectory;
@end

@implementation TemplateController

- (id)init {
    self = [super initWithWindowNibName:@"TemplatesWindow"];
    if (self) {
        self.categories = [NSMutableArray new];
        self.currentTemplates = [NSMutableArray new];
        [self loadCategories];
    }
    return self;
}

- (void)loadWindow {
    [super loadWindow];
}



- (void)loadCategories {
    NSFileManager *fm = [NSFileManager defaultManager];
    [self.categories removeAllObjects];
    for (NSString *path in [fm contentsOfDirectoryAtPath:self.templateDirectory error:nil]) {
        if ([fm directoryExistsAtPath:[self.templateDirectory stringByAppendingPathComponent:path]]) {
            [self.categories addObject:path];
        }
    }
}

- (NSString *)templateDirectory {
    NSString *applicationSupport = [ApplicationController userApplicationSupportDirectoryPath];
    return [applicationSupport stringByAppendingPathComponent:TMTTemplateDirectoryName];
}

- (void)openSavePanelForWindow:(NSWindow *)window {
    self.isSaving = YES;
    [NSApp beginSheet:self.window modalForWindow:window modalDelegate:self didEndSelector:nil contextInfo:nil];
}

- (IBAction)cancel:(id)sender {
    [NSApp endSheet:self.window];
    [self close];
    self.saveHandler(nil, NO);
}

- (void)cancelSave:(id)sender {
    [NSApp endSheet:self.sheet];
    [self.sheet close];
    self.sheet = nil;
}

- (IBAction)load:(id)sender {
}

- (IBAction)save:(id)sender {
    NSIndexSet *selection = [self.currentTemplatesView selectionIndexes];
    NSCollectionViewItem *item = [self.currentTemplates objectAtIndex:selection.firstIndex];
    if ([item isKindOfClass:[TemplatePlaceholderController class]]) {
        // TODO: Normal template!
    } else {
        if (!self.sheet) {
            [NSBundle loadNibNamed:@"AddNewTemplateWindow" owner:self];
        }
        [NSApp beginSheet:self.sheet modalForWindow:self.window modalDelegate:self didEndSelector:nil contextInfo:NULL];
    }
}

- (void)finallySave:(id)sender {
    Template *template = [Template new];
    template.category = [self.categories objectAtIndex:self.categoriesController.selectionIndex];
    template.info = self.templateDescription ? self.templateDescription : @"";
    template.name = self.templateName;
    
    [NSApp endSheet:self.sheet];
    self.sheet = nil;
    [NSApp endSheet:self.window returnCode:NSModalResponseContinue];
    self.saveHandler(template, YES);
    
}

- (NSString *)currentCategoryPath {
    NSString *category = [self.categories objectAtIndex:self.categoriesController.selectionIndex];
    return [self.templateDirectory stringByAppendingPathComponent:category];
}

- (BOOL)canSaveWithName {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *totalName = [self.templateName stringByAppendingPathExtension:TMTTemplateExtension];
    return ![fm fileExistsAtPath:[self.currentCategoryPath stringByAppendingPathComponent:totalName]];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    NSSet *keys = [super keyPathsForValuesAffectingValueForKey:key];
    if ([key isEqualToString:@"canSaveWithName"]) {
        keys = [keys setByAddingObject:@"templateName"];
    }
    return keys;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self tableViewSelectionDidChange:nil];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}


#pragma mark - Table View Delegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    
    NSString *category = [self.categories objectAtIndex:self.categoriesController.selectionIndex];
    [self loadTemplatesFromCategory:category];
}

- (void)loadTemplatesFromCategory:(NSString *)category {
    [self.currentTemplates removeAllObjects];
    [self.currentTemplates addObject:@"NewPlaceholder"];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *dir = [self.templateDirectory stringByAppendingPathComponent:category];
    for (NSString *tmpl in [fm contentsOfDirectoryAtPath:dir error:nil]) {
        if ([tmpl.pathExtension.lowercaseString isEqualToString:TMTTemplateExtension.lowercaseString]) {
            Template *template = [Template templateFromFile:[dir stringByAppendingPathComponent:tmpl]];
            [self.currentTemplates addObject:template];
        }
    }
    [self.currentTemplatesView setContent:self.currentTemplates];
}

@end
