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
+ (NSString*)templateDirectory;
+ (void)mergeDefaultTemplates;
@end

@implementation TemplateController

+ (void)initialize {
    if ([self class] == [TemplateController class]) {
        [self mergeDefaultTemplates];
    }
}

+ (void)mergeDefaultTemplates {
    NSString *templateDest = [TemplateController templateDirectory];
    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"DefaultTemplates" ofType:@"bundle"];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *categories = [fm  contentsOfDirectoryAtURL:[NSURL fileURLWithPath:sourcePath] includingPropertiesForKeys:@[NSURLIsDirectoryKey]  options:NSDirectoryEnumerationSkipsHiddenFiles error:NULL];
    
    for(NSURL *url in categories) {
        id value = nil;
        [url getResourceValue:&value forKey:NSURLIsDirectoryKey error:NULL];
        if ([value boolValue]) {
            NSString *category = [[url path] lastPathComponent];
            NSString *destCategory = [templateDest stringByAppendingPathComponent:category];
            if (![fm fileExistsAtPath:destCategory]) {
                [fm createDirectoryAtPath:destCategory withIntermediateDirectories:YES attributes:nil error:NULL];
            }
            NSArray *templates = [fm  contentsOfDirectoryAtURL:url includingPropertiesForKeys:@[NSURLIsDirectoryKey, NSURLIsPackageKey]  options:NSDirectoryEnumerationSkipsHiddenFiles error:NULL];
            for(NSURL *tmplUrl in templates) {
                NSDictionary *dict = [tmplUrl resourceValuesForKeys:@[NSURLIsPackageKey, NSURLIsDirectoryKey] error:NULL];
                if (([dict[NSURLIsDirectoryKey] boolValue] || [dict[NSURLIsPackageKey] boolValue]) && [tmplUrl.pathExtension.lowercaseString isEqualToString:TMTTemplateExtension.lowercaseString]) {
                    NSString *templateAtDest = [destCategory stringByAppendingPathComponent:tmplUrl.lastPathComponent];
                    if (![fm fileExistsAtPath:templateAtDest]) {
                        [fm copyItemAtPath:tmplUrl.path toPath:templateAtDest error:NULL];
                    }
                }
            }
        }
    }
}

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
    [self.currentTemplatesView setMaxItemSize:NSMakeSize(150, 200)];
    [self.currentTemplatesView setMinItemSize:NSMakeSize(150, 200)];
    [self.currentTemplatesView setAllowsMultipleSelection:NO];
}



- (void)loadCategories {
    NSFileManager *fm = [NSFileManager defaultManager];
    [self.categories removeAllObjects];
    for (NSString *path in [fm contentsOfDirectoryAtPath:[TemplateController templateDirectory] error:nil]) {
        if ([fm directoryExistsAtPath:[[TemplateController templateDirectory] stringByAppendingPathComponent:path]]) {
            [self.categories addObject:@{@"value":path}.mutableCopy];
        }
    }
}

+ (NSString *)templateDirectory {
    NSString *applicationSupport = [ApplicationController userApplicationSupportDirectoryPath];
    return [applicationSupport stringByAppendingPathComponent:TMTTemplateDirectoryName];
}

- (void)openSavePanelForWindow:(NSWindow *)window {
    self.isSaving = YES;
    [NSApp beginSheet:self.window modalForWindow:window modalDelegate:self didEndSelector:nil contextInfo:nil];
}

- (void)openLoadWindow {
    self.isSaving = NO;
    [self.window makeKeyAndOrderFront:self];
}

- (IBAction)cancel:(id)sender {
    [NSApp endSheet:self.window];
    [self close];
    self.sheet = nil;
    if (self.saveHandler) {
        self.saveHandler(nil, NO);
    }
    if (self.loadHandler) {
        self.loadHandler(nil, NO);
    }
}

- (void)cancelSave:(id)sender {
    [NSApp endSheet:self.sheet];
    [self.sheet close];
    self.sheet = nil;
}

- (IBAction)load:(id)sender {
    Template *template = [self.currentTemplates objectAtIndex:self.currentTemplatesView.selectionIndexes.firstIndex];
    self.loadHandler(template, YES);
}

- (IBAction)save:(id)sender {
    NSIndexSet *selection = [self.currentTemplatesView selectionIndexes];
    NSUInteger index = selection.firstIndex == NSNotFound ? 0 : selection.firstIndex;
    id item = [self.currentTemplates objectAtIndex:index];
    if ([item isKindOfClass:[Template class]]) {
        Template *template = (Template *)item;
        self.templateName = template.name;
        self.templateDescription = template.info;
        self.overrideAllowed = YES;
    } else {
        self.overrideAllowed = NO;
    }
    if (!self.sheet) {
       [NSBundle loadNibNamed:@"AddNewTemplateWindow" owner:self];
    }
    [NSApp beginSheet:self.sheet modalForWindow:self.window modalDelegate:self didEndSelector:nil contextInfo:NULL];
}

- (void)finallySave:(id)sender {
    Template *template = [Template new];
    template.category = [self.categories objectAtIndex:self.categoriesController.selectionIndex][@"value"];
    template.info = self.templateDescription ? self.templateDescription : @"";
    template.name = self.templateName;
    
    [NSApp endSheet:self.sheet];
    [self.sheet close];
    self.sheet = nil;
    [NSApp endSheet:self.window];
    [self.window close];
    self.saveHandler(template, YES);
    
}

- (NSString *)currentCategoryPath {
    NSString *category = [self.categories objectAtIndex:self.categoriesController.selectionIndex][@"value"];
    return [[TemplateController templateDirectory] stringByAppendingPathComponent:category];
}

- (IBAction)removeTemplate:(id)sender {
    Template *template = [self.currentTemplates objectAtIndex:self.currentTemplatesView.selectionIndexes.firstIndex];
    if (template) {
        NSAlert *alert = [NSAlert alertWithMessageText:[NSString stringWithFormat:NSLocalizedString(@"Are you sure to delete the template %@", @"Are you sure to delete the template [template name]"), template.name] defaultButton:NSLocalizedString(@"Remove", @"Remove Button") alternateButton:NSLocalizedString(@"Cancel", @"Cancel") otherButton:nil informativeTextWithFormat:@""];
        NSModalResponse response = [alert runModal];
        if (response == NSAlertDefaultReturn) {
            if([template remove:NULL]) {
                [self tableViewSelectionDidChange:nil];
            }
        }
    } else {
        NSBeep();
    }
}

- (BOOL)canSaveEdit {
    NSUInteger index = self.currentTemplatesView.selectionIndexes.firstIndex;
    BOOL nameUnchanged = NO;
    if (index > 0 && index != NSNotFound) {
        Template *template = [self.currentTemplates objectAtIndex:self.currentTemplatesView.selectionIndexes.firstIndex];
        nameUnchanged = [self.templateName isEqualToString:template.name];
    }
    return !self.templateExists || nameUnchanged;
}

- (IBAction)editTemplate:(id)sender {
    NSUInteger index = self.currentTemplatesView.selectionIndexes.firstIndex;
    Template *template = [self.currentTemplates objectAtIndex:index];
    self.templateName = template.name;
    self.templateDescription = template.info;
        editPopover = [NSPopover new];
        editPopover.behavior = NSPopoverBehaviorTransient;
        NSViewController *vc = [[NSViewController alloc] initWithNibName:@"EditTemplateView" bundle:nil];
        vc.representedObject = self;
        editPopover.contentViewController = vc;
        [editPopover showRelativeToRect:[self.currentTemplatesView frameForItemAtIndex:index]  ofView:self.currentTemplatesView preferredEdge:NSMaxYEdge];
}

- (void)saveEditTemplate:(id)sender {
    Template *template = [self.currentTemplates objectAtIndex:self.currentTemplatesView.selectionIndexes.firstIndex];
    template.info = self.templateDescription;
    [template save:NULL];
    NSError *error = nil;
    [template rename:self.templateName withError:&error];
    if (error) {
        [[NSAlert alertWithError:error] runModal];
    }
    [editPopover close];
    editPopover = nil;
}

- (BOOL)canSaveWithName {
    return !self.templateExists || (self.overrideAllowed && self.templateName.length > 0);
}

- (BOOL)canLoad {
    return self.currentTemplatesView.selectionIndexes.firstIndex != NSNotFound;
}

- (BOOL)templateExists {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *totalName = [self.templateName stringByAppendingPathExtension:TMTTemplateExtension];
    return [fm fileExistsAtPath:[self.currentCategoryPath stringByAppendingPathComponent:totalName]];
}

- (BOOL)canRemoveTemplate {
    return self.currentTemplatesView.selectionIndexes.firstIndex > 0 && self.currentTemplatesView.selectionIndexes.firstIndex != NSNotFound;
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    NSSet *keys = [super keyPathsForValuesAffectingValueForKey:key];
    if ([key isEqualToString:@"canSaveWithName"]) {
        keys = [keys setByAddingObjectsFromArray:@[@"templateExists", @"overrideAllowed", @"templateName"]];
    } else if([key isEqualToString:@"templateExists"]) {
        keys = [keys setByAddingObjectsFromArray:@[@"templateName", @"currentCategoryPath"]];
        
    } else if([key isEqualToString:@"canRemoveTemplate"] || [key isEqualToString:@"canLoad"]) {
        keys = [keys setByAddingObjectsFromArray:@[@"currentTemplatesView.selectionIndexes.firstIndex"]];
    } else if([key isEqualToString:@"canSaveEdit"]) {
        keys = [keys setByAddingObjectsFromArray:@[@"templateName", @"currentCategoryPath", @"templateExists"]];
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
    NSUInteger index = self.categoriesController.selectionIndex;
    if (index == NSNotFound) {
        return;
    }
    NSString *category = [self.categories objectAtIndex:index][@"value"];
    [self loadTemplatesFromCategory:category];
}


- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
    NSString *newName = fieldEditor.string;
    NSString *oldName = [self.categories objectAtIndex:self.categoriesController.selectionIndex][@"value"];
    if (!oldName || oldName.length == 0) {
        return YES;
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL success = [fm moveItemAtPath:[[TemplateController templateDirectory] stringByAppendingPathComponent:oldName] toPath:[[TemplateController templateDirectory] stringByAppendingPathComponent:newName] error:nil];
    return success;
}


- (void)loadTemplatesFromCategory:(NSString *)category {
    [self.currentTemplates removeAllObjects];
    if (self.isSaving) {
        [self.currentTemplates addObject:@"NewPlaceholder"];
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *dir = [[TemplateController templateDirectory] stringByAppendingPathComponent:category];
    for (NSString *tmpl in [fm contentsOfDirectoryAtPath:dir error:nil]) {
        if ([tmpl.pathExtension.lowercaseString isEqualToString:TMTTemplateExtension.lowercaseString]) {
            Template *template = [Template templateFromFile:[dir stringByAppendingPathComponent:tmpl]];
            [self.currentTemplates addObject:template];
        }
    }
    [self.currentTemplatesView setContent:self.currentTemplates];
    [self.currentTemplatesView setSelectionIndexes:[NSIndexSet indexSetWithIndex:0]];
}

@end
