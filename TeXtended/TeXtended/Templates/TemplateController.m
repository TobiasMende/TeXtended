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
#import "TemplatesCollectionView.h"

LOGGING_DEFAULT

static NSString *TMTTemplateTypeKey = @"TMTTemplateTypeKey";

@interface TemplateController ()

    - (void)loadCategories;

    - (void)loadTemplatesFromCategory:(NSString *)category;

    + (NSString *)templateDirectory;

    + (void)mergeDefaultTemplates;

    + (NSMutableArray *)loadTemplateIndex;

    + (void)saveTemplateIndex:(NSArray *)index;
@end

@implementation TemplateController

    + (void)initialize
    {
        if ([self class] == [TemplateController class]) {
            [self mergeDefaultTemplates];
        }
    }

    + (void)mergeDefaultTemplates
    {
        NSMutableArray *templateIndex = [self loadTemplateIndex];
        NSString *templateDest = [TemplateController templateDirectory];
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"DefaultTemplates" ofType:@"bundle"];
        NSFileManager *fm = [NSFileManager defaultManager];
        NSArray *categories = [fm contentsOfDirectoryAtURL:[NSURL fileURLWithPath:sourcePath] includingPropertiesForKeys:@[NSURLIsDirectoryKey] options:NSDirectoryEnumerationSkipsHiddenFiles error:NULL];

        for (NSURL *url in categories) {
            id value = nil;
            [url getResourceValue:&value forKey:NSURLIsDirectoryKey error:NULL];
            if ([value boolValue]) {
                NSString *category = [[url path] lastPathComponent];
                NSString *destCategory = [templateDest stringByAppendingPathComponent:category];
                BOOL needToCreateCategory = ![fm fileExistsAtPath:destCategory];
                NSArray *templates = [fm contentsOfDirectoryAtURL:url includingPropertiesForKeys:@[NSURLIsDirectoryKey, NSURLIsPackageKey] options:NSDirectoryEnumerationSkipsHiddenFiles error:NULL];
                for (NSURL *tmplUrl in templates) {
                    NSDictionary *dict = [tmplUrl resourceValuesForKeys:@[NSURLIsPackageKey, NSURLIsDirectoryKey] error:NULL];
                    if (([dict[NSURLIsDirectoryKey] boolValue] || [dict[NSURLIsPackageKey] boolValue]) && [tmplUrl.pathExtension.lowercaseString isEqualToString:TMTTemplateExtension.lowercaseString]) {
                        NSString *templateAtDest = [destCategory stringByAppendingPathComponent:tmplUrl.lastPathComponent];
                        Template *tmp = [Template templateFromFile:tmplUrl.path];
                        if (![templateIndex containsObject:@(tmp.uid)] && ![fm fileExistsAtPath:templateAtDest]) {
                            if (needToCreateCategory) {
                                [fm createDirectoryAtPath:destCategory withIntermediateDirectories:YES attributes:nil error:NULL];
                                needToCreateCategory = NO;
                            }
                            if ([fm copyItemAtPath:tmplUrl.path toPath:templateAtDest error:NULL]) {
                                [templateIndex addObject:@(tmp.uid)];
                            }
                        }
                    }
                }
            }
        }

        [self saveTemplateIndex:templateIndex];
    }

    - (id)init
    {
        self = [super initWithWindowNibName:@"TemplatesWindow"];
        if (self) {
            self.categories = [NSMutableArray new];
            self.currentTemplates = [NSMutableArray new];
            [self loadCategories];
        }
        return self;
    }


    - (void)loadCategories
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        [self.categories removeAllObjects];
        [self.categories addObject:@{@"value" : NSLocalizedString(@"All Templates", @"All Templates Category")}];
        for (NSString *path in [fm contentsOfDirectoryAtPath:[TemplateController templateDirectory] error:nil]) {
            if ([fm directoryExistsAtPath:[[TemplateController templateDirectory] stringByAppendingPathComponent:path]]) {
                [self.categories addObject:@{@"value" : path}.mutableCopy];
            }
        }
        [self.categoriesController rearrangeObjects];
    }

    + (NSString *)templateDirectory
    {
        NSString *applicationSupport = [ApplicationController userApplicationSupportDirectoryPath];
        return [applicationSupport stringByAppendingPathComponent:TMTTemplateDirectoryName];
    }

    + (NSMutableArray *)loadTemplateIndex
    {
        NSString *path = [[self templateDirectory] stringByAppendingPathComponent:@"templates.index"];
        NSMutableArray *array = [NSMutableArray arrayWithContentsOfFile:path];
        if (!array) {
            array = [NSMutableArray new];
        }
        return array;
    }

    + (void)saveTemplateIndex:(NSArray *)index
    {
        NSString *path = [[self templateDirectory] stringByAppendingPathComponent:@"templates.index"];
        [index writeToFile:path atomically:YES];
    }

    - (IBAction)deleteCategory:(id)sender
    {
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Are you sure to delete the category? All contained templates will be deleted.", @"Are you sure to delete the category? All contained templates will be deleted.") defaultButton:NSLocalizedString(@"Remove", @"Remove Button") alternateButton:NSLocalizedString(@"Cancel", @"Cancel") otherButton:nil informativeTextWithFormat:@""];
        NSModalResponse response = [alert runModal];
        if (response == NSAlertDefaultReturn) {
            NSFileManager *fm = [NSFileManager defaultManager];
            if ([fm removeItemAtPath:self.currentCategoryPath error:NULL]) {
                [self loadCategories];
            }

        }
    }

    - (void)openSavePanelForWindow:(NSWindow *)window
    {
        self.isSaving = YES;
        [NSApp beginSheet:self.window modalForWindow:window modalDelegate:self didEndSelector:nil contextInfo:nil];
    }

    - (void)openLoadWindow
    {
        self.isSaving = NO;
        [self.window makeKeyAndOrderFront:self];
    }

    - (IBAction)cancel:(id)sender
    {
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

    - (void)cancelSave:(id)sender
    {
        [NSApp endSheet:self.sheet];
        [self.sheet close];
        self.sheet = nil;
    }

    - (IBAction)load:(id)sender
    {
        Template *template = [self.currentTemplates objectAtIndex:self.currentTemplatesView.selectionIndexes.firstIndex];
        self.loadHandler(template, YES);
        [self close];
    }

    - (IBAction)save:(id)sender
    {
        NSIndexSet *selection = [self.currentTemplatesView selectionIndexes];
        NSUInteger index = selection.firstIndex == NSNotFound ? 0 : selection.firstIndex;
        id item = [self.currentTemplates objectAtIndex:index];
        if ([item isKindOfClass:[Template class]]) {
            Template *template = (Template *) item;
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

    - (void)finallySave:(id)sender
    {
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

    - (NSString *)currentCategoryPath
    {
        NSString *category = [self.categories objectAtIndex:self.categoriesController.selectionIndex][@"value"];
        return [[TemplateController templateDirectory] stringByAppendingPathComponent:category];
    }

    - (IBAction)removeTemplate:(id)sender
    {
        Template *template = [self.currentTemplates objectAtIndex:self.currentTemplatesView.selectionIndexes.firstIndex];
        if (template) {
            NSAlert *alert = [NSAlert alertWithMessageText:[NSString stringWithFormat:NSLocalizedString(@"Are you sure to delete the template %@", @"Are you sure to delete the template [template name]"), template.name] defaultButton:NSLocalizedString(@"Remove", @"Remove Button") alternateButton:NSLocalizedString(@"Cancel", @"Cancel") otherButton:nil informativeTextWithFormat:@""];
            NSModalResponse response = [alert runModal];
            if (response == NSAlertDefaultReturn) {
                if ([template remove:NULL]) {
                    [self tableViewSelectionDidChange:nil];
                }
            }
        } else {
            NSBeep();
        }
    }

    - (BOOL)canSaveEdit
    {
        NSUInteger index = self.currentTemplatesView.selectionIndexes.firstIndex;
        BOOL nameUnchanged = NO;
        if (index > 0 && index != NSNotFound) {
            Template *template = [self.currentTemplates objectAtIndex:self.currentTemplatesView.selectionIndexes.firstIndex];
            nameUnchanged = [self.templateName isEqualToString:template.name];
        }
        return !self.templateExists || nameUnchanged;
    }

    - (IBAction)editTemplate:(id)sender
    {
        NSUInteger index = self.currentTemplatesView.selectionIndexes.firstIndex;
        Template *template = [self.currentTemplates objectAtIndex:index];
        self.templateName = template.name;
        self.templateDescription = template.info;
        editPopover = [NSPopover new];
        editPopover.behavior = NSPopoverBehaviorTransient;
        NSViewController *vc = [[NSViewController alloc] initWithNibName:@"EditTemplateView" bundle:nil];
        vc.representedObject = self;
        editPopover.contentViewController = vc;
        [editPopover showRelativeToRect:[self.currentTemplatesView frameForItemAtIndex:index] ofView:self.currentTemplatesView preferredEdge:NSMaxYEdge];
    }

    - (void)saveEditTemplate:(id)sender
    {
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

    - (BOOL)canSaveWithName
    {
        return !self.templateExists || (self.overrideAllowed && self.templateName.length > 0);
    }

    - (BOOL)canLoad
    {
        return self.currentTemplatesView.selectionIndexes.firstIndex != NSNotFound;
    }


    - (BOOL)templateExists
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *totalName = [self.templateName stringByAppendingPathExtension:TMTTemplateExtension];
        return [fm fileExistsAtPath:[self.currentCategoryPath stringByAppendingPathComponent:totalName]];
    }

    - (BOOL)canRemoveTemplate
    {
        return self.currentTemplatesView.selectionIndexes.firstIndex > 0 && self.currentTemplatesView.selectionIndexes.firstIndex != NSNotFound;
    }

    + (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
    {
        NSSet *keys = [super keyPathsForValuesAffectingValueForKey:key];
        if ([key isEqualToString:@"canSaveWithName"]) {
            keys = [keys setByAddingObjectsFromArray:@[@"templateExists", @"overrideAllowed", @"templateName"]];
        } else if ([key isEqualToString:@"templateExists"]) {
            keys = [keys setByAddingObjectsFromArray:@[@"templateName", @"currentCategoryPath"]];

        } else if ([key isEqualToString:@"canRemoveTemplate"] || [key isEqualToString:@"canLoad"]) {
            keys = [keys setByAddingObjectsFromArray:@[@"currentTemplatesView.selectionIndexes.firstIndex"]];
        } else if ([key isEqualToString:@"canSaveEdit"]) {
            keys = [keys setByAddingObjectsFromArray:@[@"templateName", @"currentCategoryPath", @"templateExists"]];
        } else if ([key isEqualToString:@"canDeleteCategory"]) {
            keys = [keys setByAddingObjectsFromArray:@[@"currentTemplates", @"isSaving"]];
        }
        return keys;
    }

    - (void)windowDidLoad
    {
        [super windowDidLoad];
        [self.currentTemplatesView setMaxItemSize:NSMakeSize(150, 200)];
        [self.currentTemplatesView setMinItemSize:NSMakeSize(150, 200)];
        [self.currentTemplatesView setAllowsMultipleSelection:NO];
        [self.categoriesView registerForDraggedTypes:@[NSURLPboardType]];
        [self.currentTemplatesView registerForDraggedTypes:@[NSURLPboardType]];
        [self tableViewSelectionDidChange:nil];
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }


#pragma mark - Table View Delegate

    - (void)tableViewSelectionDidChange:(NSNotification *)notification
    {
        NSUInteger index = self.categoriesController.selectionIndex;
        if (index == NSNotFound) {
            return;
        }
        NSString *category = index == 0 ? nil : [self.categories objectAtIndex:index][@"value"];
        [self loadTemplatesFromCategory:category];
    }


    - (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
    {
        NSString *newName = fieldEditor.string;
        NSString *oldName = [self.categories objectAtIndex:self.categoriesController.selectionIndex][@"value"];
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm directoryExistsAtPath:[[TemplateController templateDirectory] stringByAppendingPathComponent:newName]]) {
            return NO;
        }
        if (!oldName || oldName.length == 0) {
            [fm createDirectoryAtPath:[[TemplateController templateDirectory] stringByAppendingPathComponent:newName] withIntermediateDirectories:YES attributes:nil error:NULL];
            return YES;
        }
        BOOL success = [fm moveItemAtPath:[[TemplateController templateDirectory] stringByAppendingPathComponent:oldName] toPath:[[TemplateController templateDirectory] stringByAppendingPathComponent:newName] error:nil];
        return success;
    }


    - (void)loadTemplatesFromCategory:(NSString *)category
    {
        [self.currentTemplates removeAllObjects];
        if (self.isSaving) {
            [self.currentTemplates addObject:@"NewPlaceholder"];
        }
        NSFileManager *fm = [NSFileManager defaultManager];
        NSMutableArray *categoriesToShow;
        if (!category) {
            categoriesToShow = [NSMutableArray arrayWithCapacity:self.categories.count - 1];
            NSEnumerator *iterator = self.categories.objectEnumerator;
            (void)iterator.nextObject; //Skip "All Templates"
            for (NSDictionary *dict in iterator) {
                [categoriesToShow addObject:dict[@"value"]];
            }
        } else {
            categoriesToShow = [NSMutableArray arrayWithObject:category];
        }

        for (NSString *categoryName in categoriesToShow) {
            NSString *dir = [[TemplateController templateDirectory] stringByAppendingPathComponent:categoryName];
            for (NSString *tmpl in [fm contentsOfDirectoryAtPath:dir error:nil]) {
                if ([tmpl.pathExtension.lowercaseString isEqualToString:TMTTemplateExtension.lowercaseString]) {
                    Template *template = [Template templateFromFile:[dir stringByAppendingPathComponent:tmpl]];
                    [self.currentTemplates addObject:template];
                }
            }
        }
        [self.currentTemplatesView setContent:self.currentTemplates];
        [self.currentTemplatesView setSelectionIndexes:[NSIndexSet indexSetWithIndex:0]];
    }


#pragma mark - Drag and Drop

    - (BOOL)collectionView:(NSCollectionView *)collectionView canDragItemsAtIndexes:(NSIndexSet *)indexes withEvent:(NSEvent *)event
    {
        if (self.isSaving) {
            return ![indexes containsIndex:0];
        } else {
            return YES;
        }
    }


    - (NSDragOperation)collectionView:(NSCollectionView *)collectionView validateDrop:(id <NSDraggingInfo>)info proposedIndex:(NSInteger *)proposedDropIndex dropOperation:(NSCollectionViewDropOperation *)proposedDropOperation
    {
        if ((self.isSaving && proposedDropIndex == 0)) {
            return NSDragOperationNone;
        }
        if ([collectionView isEqualTo:[info draggingSource]]) {
            return NSDragOperationNone;
        }
        NSPasteboard *pb = info.draggingPasteboard;
        NSArray *urls = [pb readObjectsForClasses:@[[NSURL class]]
                                          options:nil];
        if (urls.count > 0) {
            *proposedDropOperation = NSCollectionViewDropOn;
            if (*proposedDropIndex >= (NSInteger)self.currentTemplates.count) {
                if (*proposedDropIndex < 0) {
                    *proposedDropIndex = *proposedDropIndex - 1;
                } else {
                    return NSDragOperationNone;
                }
            } else if (*proposedDropIndex < 0) {
                *proposedDropIndex = self.currentTemplates.count;
            }
            return NSDragOperationCopy;
        }

        return NSDragOperationNone;

    }


    - (BOOL)collectionView:(NSCollectionView *)collectionView acceptDrop:(id <NSDraggingInfo>)info index:(NSInteger)index dropOperation:(NSCollectionViewDropOperation)dropOperation
    {
        if (dropOperation != NSCollectionViewDropOn || (self.isSaving && index == 0)) {
            return NO;
        }

        NSPasteboard *pb = info.draggingPasteboard;
        NSArray *urls = [pb readObjectsForClasses:[NSArray arrayWithObject:[NSURL class]]
                                          options:nil];
        Template *tmpl = [self.currentTemplates objectAtIndex:index];
        if (!tmpl) {
            return NO;
        }
        if (urls.count == 1 && [[urls.firstObject pathExtension].lowercaseString isEqualToString:@"pdf"]) {
            if ([tmpl replacePreviewPdf:[urls.firstObject path]]) {
                [self tableViewSelectionDidChange:nil];
                return YES;
            }
            return NO;
        }
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL hasCopied = NO;
        for (NSURL *url in urls) {
            NSString *name = url.lastPathComponent;
            BOOL shouldWrite = YES;
            NSString *destPath = [tmpl.contentPath stringByAppendingPathComponent:name];
            if ([fm fileExistsAtPath:destPath]) {
                NSAlert *override = [NSAlert alertWithMessageText:[NSString stringWithFormat:NSLocalizedString(@"File %@ exists. Do you wan't to overwrite it?", @"File [file name] exists. Do you wan't to overwrite it?"), name] defaultButton:NSLocalizedString(@"Override", @"Override") alternateButton:NSLocalizedString(@"Cancel", @"Cancel") otherButton:nil informativeTextWithFormat:@""];
                override.alertStyle = NSWarningAlertStyle;
                if ([override runModal] == NSModalResponseOK) {
                    [fm removeItemAtPath:destPath error:NULL];
                } else {
                    shouldWrite = NO;
                }
            }

            if (shouldWrite) {
                NSError *error = nil;
                [fm copyItemAtPath:url.path toPath:destPath error:&error];
                if (error) {
                    [NSAlert alertWithError:error];
                } else {
                    hasCopied = YES;
                }
            }


        }


        return hasCopied;
    }

    - (BOOL)collectionView:(NSCollectionView *)collectionView writeItemsAtIndexes:(NSIndexSet *)indexes toPasteboard:(NSPasteboard *)pasteboard
    {
        [pasteboard declareTypes:@[NSURLPboardType] owner:self];
        NSArray *templates = [self.currentTemplates objectsAtIndexes:indexes];
        NSMutableArray *content = [NSMutableArray arrayWithCapacity:templates.count];
        for (id obj in templates) {
            if ([obj isKindOfClass:[Template class]]) {
                NSURL *url = [NSURL fileURLWithPath:[(Template *) obj templatePath]];
                [content addObject:url];
            }
        }
        BOOL success = [pasteboard writeObjects:content];
        return success && content.count > 0;
    }

    - (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id <NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation
    {
        if (dropOperation == NSTableViewDropAbove) {
            return NO;
        }
        if (row == 0) {
            return NO;
        }
        if (((NSInteger)self.categoriesController.selectionIndex == row && [[info draggingSource] isKindOfClass:[TemplatesCollectionView class]])) {
            return NO;
        }

        NSString *category = [self.categories objectAtIndex:row][@"value"];
        NSPasteboard *pb = [info draggingPasteboard];
        NSArray *urls = [pb readObjectsForClasses:[NSArray arrayWithObject:[NSURL class]]
                                          options:nil];
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL success = YES;
        for (NSURL *url in urls) {
            NSString *sourcePath = url.path;
            NSString *destPath = [[[TemplateController templateDirectory] stringByAppendingPathComponent:category] stringByAppendingPathComponent:sourcePath.lastPathComponent];
            NSError *error;
            if (![fm directoryExistsAtPath:destPath.stringByDeletingLastPathComponent]) {
                [fm createDirectoryAtPath:destPath.stringByDeletingLastPathComponent withIntermediateDirectories:YES attributes:nil error:NULL];
            }
            if ([info draggingSourceOperationMask] == NSDragOperationCopy) {
                success &= [fm copyItemAtPath:sourcePath toPath:destPath error:&error];
            } else {
                success &= [fm moveItemAtPath:sourcePath toPath:destPath error:&error];
            }
            if (error) {
                DDLogError(@"%@", error);
            }
        }
        if (success) {
            [self tableViewSelectionDidChange:nil];
        }
        return success;
    }

    - (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation
    {
        if (dropOperation == NSTableViewDropAbove) {
            return NSDragOperationNone;
        }
        if (row == 0) {
            return NSDragOperationNone;
        }
        NSPasteboard *pb = info.draggingPasteboard;
        NSArray *urls = [pb readObjectsForClasses:[NSArray arrayWithObject:[NSURL class]]
                                          options:nil];
        NSMutableArray *final = [NSMutableArray arrayWithCapacity:urls.count];
        for (NSURL *url in urls) {
            if ([url.pathExtension.lowercaseString isEqualToString:TMTTemplateExtension.lowercaseString]) {
                [final addObject:url];
            }
        }
        if (final.count == 0 || ((NSInteger)self.categoriesController.selectionIndex == row && [[info draggingSource] isKindOfClass:[TemplatesCollectionView class]])) {
            return NSDragOperationNone;
        }

        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *category = [self.categories objectAtIndex:row][@"value"];
        if (category) {
            for (NSURL *url in final) {
                if ([fm fileExistsAtPath:[[[TemplateController templateDirectory] stringByAppendingPathComponent:category] stringByAppendingPathComponent:url.lastPathComponent]]) {
                    return NSDragOperationNone;
                }
            }
        }
        [info setNumberOfValidItemsForDrop:final.count];

        if ([[info draggingSource] isKindOfClass:[TemplatesCollectionView class]]) {
            return NSDragOperationMove;
        }
        return NSDragOperationCopy;
    }


@end
