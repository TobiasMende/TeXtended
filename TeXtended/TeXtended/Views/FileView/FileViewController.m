//
//  FileViewController.m
//  TeXtended
//
//  Created by Tobias Mende on 01.05.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <TMTHelperCollection/PathObserverFactory.h>
#import <TMTHelperCollection/TMTLog.h>
#import <TMTHelperCollection/TMTTextField.h>
#import <TMTHelperCollection/TMTTreeController.h>
#import <Quartz/Quartz.h>

#import "FileViewController.h"
#import "FileNode.h"
#import "DocumentCreationController.h"
#import "MainDocument.h"
#import "ModelInfoWindowController.h"
#import "FileOutlineView.h"
#import "FileInfoWindowController.h"


static const NSString *FILE_KEY_PATH = @"fileURL";

static const NSString *WINDOW_KEY_PATH = @"window";

static NSArray *INTERNAL_EXTENSIONS;


@interface FileViewController ()

    - (MainDocument *)currentMainDocument;

    - (NSString *)basePathForCreation:(NSString *)path;

    - (void)createDirectoryInDirectory:(NSString *)path;

    - (void)createFileInDirectory:(NSString *)path;

    - (void)pathObserverBuildTree;

    - (NSIndexPath *)indexPathForPath:(NSString *)path;

    - (FileNode *)findFileNodeForPath:(NSString *)path;

- (void)clearSearchResults;

@end

@implementation FileViewController

#pragma mark Init & Dealloc

    - (void)dealloc
    {
        DDLogVerbose(@"dealloc [%@]", self.path);
        [self.outlineView setViewController:nil];
        [self.document removeObserver:self forKeyPath:FILE_KEY_PATH];
        [PathObserverFactory removeObserver:self];
    }

    - (id)init
    {
        return [self initWithNibName:@"FileView" bundle:nil];
    }

    - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
    {
        self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
        if (self) {
            // Initialization code here.
            pathObserverIsActive = YES;
        }
        return self;
    }

    + (void)initialize
    {
        if ([self class] == [FileViewController class]) {
            INTERNAL_EXTENSIONS = @[@"tex", @"sty", @"cls"];
        }
    }

    - (void)awakeFromNib
    {
        [super awakeFromNib];
        [self.outlineView registerForDraggedTypes:[NSArray arrayWithObjects:NSURLPboardType, NSStringPboardType, NSFilenamesPboardType, nil]];
        [self.outlineView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:YES];
        [self.outlineView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:NO];
    }


#pragma mark - Getter

    - (FileNode *)currentFileNode
    {
        NSInteger row = self.currentRow;

        if (row < 0) {
            return nil;
        }
        return [[self.outlineView itemAtRow:row] representedObject];
    }

    - (NSInteger)currentRow
    {
        return self.outlineView.clickedRow < 0 ? self.outlineView.selectedRow : self.outlineView.clickedRow;
    }

    - (MainDocument *)currentMainDocument
    {
        if ([self.document isKindOfClass:[MainDocument class]]) {
            return self.document;
        }
        return nil;
    }


#pragma mark - Setter

    - (void)setDocument:(NSDocument *)document
    {
        if (_document) {
            [_document removeObserver:self forKeyPath:FILE_KEY_PATH];
        }
        _document = document;
        if (_document) {
            [_document addObserver:self forKeyPath:FILE_KEY_PATH options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:nil];
        }
    }

    - (void)setPath:(NSString *)path
    {
        if (![_path isEqualToString:path]) {
            if (_path) {
                [PathObserverFactory removeObserver:self];
            }
            _path = path;
            DDLogInfo(@"Setting path: %@", _path);
            if (_path) {
                [[PathObserverFactory pathObserverForPath:_path] addObserver:self withSelector:@selector(pathObserverBuildTree)];
                [self buildTree];
            }
        }
    }

    - (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
    {
        if ([keyPath isEqualToString:FILE_KEY_PATH]) {
            [self updatePath];
        }
    }

    - (void)updatePath
    {
        NSURL *url = self.document.fileURL;

        self.path = [url.path stringByDeletingLastPathComponent];
        
    }

    - (NSString *)basePathForCreation:(NSString *)path
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL isDir;

        [fm fileExistsAtPath:path isDirectory:&isDir];

        return isDir ? path : [path stringByDeletingLastPathComponent];
    }


#pragma mark - Text Delegates

    - (void)controlTextDidEndEditing:(NSNotification *)note
    {
        if (note.object != self.searchField) {
            [self buildTree];
            pathObserverIsActive = YES;
        }
    }

-(void)controlTextDidChange:(NSNotification *)note {
    if (note.object == self.searchField) {
        if ([self.searchField.stringValue isEqualToString:@""]) {
            [self clearSearchResults];
        } else {
            if (!preFilterExpandedItems) {
                preFilterExpandedItems = self.outlineView.expandedItems;
                preFilterSelectedItems = self.fileTree.selectionIndexPaths;
            }
            [self.fileTree filterContentBy:[NSPredicate predicateWithFormat:@"name contains[c] %@", self.searchField.stringValue]];
            [self.outlineView expandItem:self.fileTree.selectionIndexPaths];
            [self.outlineView scrollRowToVisible:self.outlineView.selectedRow];
        }
    }
}

- (void)clearSearchResults {
    if (preFilterExpandedItems) {
        self.fileTree.selectionIndexPaths = preFilterSelectedItems;
        [self.outlineView collapseItem:nil];
        [self.outlineView restoreExpandedStateWithArray:preFilterExpandedItems];
        preFilterExpandedItems = nil;
        preFilterSelectedItems = nil;
    }
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    if (control == self.searchField) {
        if (commandSelector == @selector(cancelOperation:)) {
            [self.view.window makeFirstResponder:self.outlineView];
            self.searchField.stringValue = @"";
            [self clearSearchResults];
            return YES;
        }
    }
    return NO;
}

    - (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item
    {
        DDLogInfo(@"Should?");
        return YES;
    }

    - (BOOL)control:(NSControl *)control isValidObject:(id)obj
    {
        if (control == self.searchField) {
            return YES;
        }
        FileNode *node = [self currentFileNode];
        NSString *basePath = [node.path stringByDeletingLastPathComponent];
        NSFileManager *fm = [NSFileManager defaultManager];

        return [obj length] > 0 && ![obj hasPrefix:@"."] && [obj rangeOfString:@"/"].location == NSNotFound && ([node.name isEqualTo:obj] || ![fm fileExistsAtPath:[basePath stringByAppendingPathComponent:obj]]);
    }

    - (void)controlDidSelectText:(TMTTextField *)control
    {
        pathObserverIsActive = NO;
        NSText *editor = [self.view.window fieldEditor:YES forObject:control];
        NSString *base = [control.stringValue stringByDeletingPathExtension];
        [editor setSelectedRange:[control.stringValue rangeOfString:base]];
    }


#pragma mark - Context Menu Actions

    - (IBAction)openFile:(id)sender
    {
        FileNode *node = self.currentFileNode;
        NSString *extension = node.path.pathExtension;

        if ([INTERNAL_EXTENSIONS containsObject:extension] && [self.document isKindOfClass:[MainDocument class]]) {
            [[DocumentCreationController sharedDocumentController] showTexDocumentForPath:node.path withReferenceModel:[(MainDocument *) self.document model] andCompletionHandler:nil];
        }
        else {
            [[NSWorkspace sharedWorkspace] openFile:node.path];
        }
    }

    - (BOOL)respondsToSelector:(SEL)aSelector
    {
        if (!self.currentMainDocument) {
            return [super respondsToSelector:aSelector];
        }
        if (aSelector == @selector(deleteFile:)) {
            FileNode *node = self.currentFileNode;
            MainDocument *md = self.currentMainDocument;
            return node && md && ![md.model.path isEqualToString:node.path];
        }

        return [super respondsToSelector:aSelector];
    }

    - (IBAction)renameFile:(id)sender
    {
        NSInteger row = self.outlineView.clickedRow < 0 ? self.outlineView.selectedRow : self.outlineView.clickedRow;

        if (row < 0) {
            NSBeep();
            return;
        }
        [self.outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];

        [self.outlineView editColumn:0 row:row withEvent:nil select:YES];
        // TODO: finish implementation
    }

    - (IBAction)deleteFile:(id)sender
    {
        pathObserverIsActive = NO;
        FileNode *node = self.currentFileNode;
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Delete File?", @"Delete File Alert Title") defaultButton:NSLocalizedString(@"Delete", @"Delete Button") alternateButton:NSLocalizedString(@"Cancel", @"Cancel Button") otherButton:nil informativeTextWithFormat:NSLocalizedString(@"Are you sure to delete the file %@", @""), node.path.lastPathComponent];
        alert.icon = node.icon;
        NSModalResponse response = [alert runModal];

        if (response == NSAlertDefaultReturn) {
            NSError *error;
            const NSInteger currentRow = self.currentRow;

            [[NSWorkspace sharedWorkspace] recycleURLs:@[[NSURL fileURLWithPath:node.path]] completionHandler:^(NSDictionary *newURLs, NSError *error)
            {
                if (error) {
                    [[NSAlert alertWithError:error] runModal];
                }
                [self buildTree];
                NSInteger row = currentRow > 0 ? currentRow - 1 : currentRow;
                [self.outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
            }];
        }

        pathObserverIsActive = YES;
    }

    - (IBAction)createNewFile:(id)sender
    {
        FileNode *node = self.currentFileNode;
        NSString *path = [self basePathForCreation:node.path];

        [self createFileInDirectory:path];
    }

    - (void)createNewFileInRoot:(id)sender
    {
        [self createFileInDirectory:self.path];
    }

    - (void)createFileInDirectory:(NSString *)path
    {
        NSFileManager *fm = [NSFileManager defaultManager];

        pathObserverIsActive = NO;
        NSString *base = NSLocalizedString(@"Untitled", @"");
        NSString *name = [NSString stringWithString:base];
        NSUInteger idx = 2;
        while ([fm fileExistsAtPath:[[path stringByAppendingPathComponent:name] stringByAppendingPathExtension:@"tex"]])
            name = [NSString stringWithFormat:@"%@ %li", base, idx++];
        NSString *totalPath = [[path stringByAppendingPathComponent:name] stringByAppendingPathExtension:@"tex"];
        NSError *error;
        [fm createFileAtPath:totalPath contents:[@"" dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
        if (error) {
            [[NSAlert alertWithError:error] runModal];
        }
        else {
            [self buildTree];
            NSIndexPath *indexes = [self indexPathForPath:totalPath];
            if ([self.fileTree setSelectionIndexPath:indexes] && self.outlineView.selectedRow >= 0) {
                [self.outlineView editColumn:0 row:self.outlineView.selectedRow withEvent:nil select:YES];
            }
        }
    }

    - (IBAction)createNewFolder:(id)sender
    {
        FileNode *node = self.currentFileNode;
        NSString *path = [self basePathForCreation:node.path];

        [self createDirectoryInDirectory:path];
    }

    - (void)createNewFolderInRoot:(id)sender
    {
        [self createDirectoryInDirectory:self.path];
    }

    - (void)createDirectoryInDirectory:(NSString *)path
    {
        NSFileManager *fm = [NSFileManager defaultManager];

        pathObserverIsActive = NO;
        NSString *base = NSLocalizedString(@"Untitled Folder", @"");
        NSString *name = [NSString stringWithString:base];
        NSUInteger idx = 2;
        while ([fm fileExistsAtPath:[path stringByAppendingPathComponent:name]])
            name = [NSString stringWithFormat:@"%@ %li", base, idx++];
        NSString *totalPath = [path stringByAppendingPathComponent:name];
        NSError *error;
        [fm createDirectoryAtPath:totalPath withIntermediateDirectories:NO attributes:nil error:&error];
        if (error) {
            [[NSAlert alertWithError:error] runModal];
        }
        else {
            [self buildTree];
            NSIndexPath *indexes = [self indexPathForPath:totalPath];
            if ([self.fileTree setSelectionIndexPath:indexes] && self.outlineView.selectedRow >= 0) {
                [self.outlineView editColumn:0 row:self.outlineView.selectedRow withEvent:nil select:YES];
            }
        }
    }

    - (IBAction)revealInFinder:(id)sender
    {
        FileNode *node = self.currentFileNode;

        [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[[NSURL fileURLWithPath:node.path]]];
    }

    - (void)openRootInFinder:(id)sender
    {
        [[NSWorkspace sharedWorkspace] openFile:self.path];
    }

    - (IBAction)showInformation:(id)sender
    {
        FileNode *node = self.currentFileNode;
        Compilable *model;

        if ([INTERNAL_EXTENSIONS containsObject:node.path.pathExtension]) {
            model = [self.currentMainDocument.model modelForTexPath:node.path byCreating:YES];
        }
        else if ([node.path.pathExtension.lowercaseString isEqualToString:@"texpf"]) {
            NSDocument *doc = [[NSDocumentController sharedDocumentController] documentForURL:[NSURL fileURLWithPath:node.path]];
            if (doc && [doc isKindOfClass:[MainDocument class]]) {
                model = ((MainDocument *) doc).model;
            }
        }
        if (model) {
            if (!self.infoWindowController) {
                self.infoWindowController = [ModelInfoWindowController sharedInstance];
            }
            self.infoWindowController.model = model;
            [self.infoWindowController showWindow:self];
        }
        else {
            if (!self.fileInfoWindowController) {
                self.fileInfoWindowController = [FileInfoWindowController new];
            }
            self.fileInfoWindowController.fileURL = node.fileURL;
            [self.fileInfoWindowController showWindow:self];
            
        }
    }



#pragma mark - Drag & Drop

    - (NSDragOperation)outlineView:(NSOutlineView *)ov validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)childIndex
    {
        NSArray *types = [[info draggingPasteboard] types];

        if (![types containsObject:NSURLPboardType] || ![types containsObject:NSFilenamesPboardType]) {
            return NSDragOperationNone;
        }
        FileNode *node = [item representedObject];
        id finalItem = item;
        if ([node isLeaf]) {
            NSTreeNode *parent = [item parentNode];
            if (parent) {
                [self.outlineView setDropItem:parent dropChildIndex:NSOutlineViewDropOnItemIndex];
            }
        }
        return NSDragOperationGeneric;
    }

    - (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id <NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index
    {
        NSArray *objects = [[info draggingPasteboard] readObjectsForClasses:@[[NSURL class]] options:@{NSPasteboardURLReadingFileURLsOnlyKey : @(YES)}];

        if (objects) {
            pathObserverIsActive = NO;
            NSString *destPath = item ? [[item representedObject] path] : self.path;
            NSURL *destination = [NSURL fileURLWithPath:destPath];
            NSMutableArray *failedURLS = [NSMutableArray new];
            NSMutableArray *errors = [NSMutableArray new];
            NSFileManager *fm = [NSFileManager defaultManager];
            for (NSURL *url in objects) {
                NSError *moveError;
                BOOL success = [fm moveItemAtURL:url toURL:[destination URLByAppendingPathComponent:url.lastPathComponent] error:&moveError];
                if (!success) {
                    [failedURLS addObject:url];
                }
                if (moveError) {
                    DDLogError(@"Error while moving %@: %@0", url.lastPathComponent, moveError.userInfo);
                    [errors addObject:moveError];
                }
            }
            [self buildTree];
            if (failedURLS.count > 0) {
                NSAlert *alert;
                if (errors.count == 1) {
                    alert = [NSAlert alertWithError:errors.firstObject];
                }
                else {
                    NSMutableString *description = [NSMutableString new];
                    for (NSURL *url in failedURLS) {
                        [description appendFormat:@" - %@\n", url.lastPathComponent];
                    }
                    [description deleteCharactersInRange:NSMakeRange(description.length - 1, 1)];
                    alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Error while moving files", @"") defaultButton:NSLocalizedString(@"Okay", @"") alternateButton:nil otherButton:nil informativeTextWithFormat:NSLocalizedString(@"Failed to move the following files:\n%@", @""), description];

                    alert.alertStyle = NSCriticalAlertStyle;
                }
                [alert runModal];
            }
            pathObserverIsActive = YES;
        }

        return YES;
    }

    - (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pasteboard
    {
        return YES;
    }

    - (id <NSPasteboardWriting>)outlineView:(NSOutlineView *)outlineView pasteboardWriterForItem:(id)item
    {
        return (id <NSPasteboardWriting>) [item representedObject];
    }

    - (void)outlineView:(NSOutlineView *)outlineView draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation
    {
        // If the session ended in the trash, then delete all the items
        pathObserverIsActive = NO;
        [self buildTree];
        pathObserverIsActive = YES;
    }


# pragma mark - Tree Helpers

    - (void)pathObserverBuildTree
    {
        if (pathObserverIsActive) {
            [self buildTree];
        }
    }

    - (void)buildTree
    {
        [self.fileTree discardEditing];
        NSArray *expandedItems = [self.outlineView expandedItems];
        NSError *error;
        FileNode *root = [FileNode fileNodeWithPath:self.path];
        self.contents = root.children;
        [self.fileTree rearrangeObjects];
        [self.outlineView restoreExpandedStateWithArray:expandedItems];
    }

    - (NSIndexPath *)indexPathForPath:(NSString *)path
    {
        if (![path hasPrefix:self.path]) {
            return nil;
        }
        NSUInteger count = 0;
        for (FileNode *node in self.contents) {
            NSIndexPath *result = [node indexPathForPath:path andPrefix:[NSIndexPath indexPathWithIndex:count]];
            if (result) {
                return result;
            }
            count++;
        }
        return nil;
    }

    - (FileNode *)findFileNodeForPath:(NSString *)path
    {
        for (FileNode *node in self.contents) {
            FileNode *result = [node fileNodeForPath:path];
            if (result) {
                return result;
            }
        }
        return nil;
    }


#pragma mark - Quick Look panel support

    - (void)outlineViewSelectionDidChange:(NSNotification *)notification
    {
        [self.previewPanel reloadData];
    }

    - (BOOL)acceptsPreviewPanelControl:(QLPreviewPanel *)panel
    {
        return YES;
    }

    - (void)beginPreviewPanelControl:(QLPreviewPanel *)panel
    {
        // This document is now responsible of the preview panel
        // It is allowed to set the delegate, data source and refresh panel.
        //
        _previewPanel = panel;
        panel.delegate = self;
        panel.dataSource = self;
    }

    - (void)endPreviewPanelControl:(QLPreviewPanel *)panel
    {
        // This document loses its responsisibility on the preview panel
        // Until the next call to -beginPreviewPanelControl: it must not
        // change the panel's delegate, data source or refresh it.
        //
        _previewPanel = nil;
    }


#pragma mark - QLPreviewPanelDataSource

    - (NSInteger)numberOfPreviewItemsInPreviewPanel:(QLPreviewPanel *)panel
    {
        return 1;
    }

    - (id <QLPreviewItem>)previewPanel:(QLPreviewPanel *)panel previewItemAtIndex:(NSInteger)index
    {
        return self.currentFileNode;
    }


#pragma mark - QLPreviewPanelDelegate

    - (BOOL)previewPanel:(QLPreviewPanel *)panel handleEvent:(NSEvent *)event
    {
        // redirect all key down events to the table view
        if ([event type] == NSKeyDown) {
            [self.outlineView keyDown:event];
            return YES;
        }
        return NO;
    }

// This delegate method provides the rect on screen from which the panel will zoom.
    - (NSRect)previewPanel:(QLPreviewPanel *)panel sourceFrameOnScreenForPreviewItem:(id <QLPreviewItem>)item
    {
        FileNode *node = [FileNode new];

        node.path = [item previewItemURL].path;
        NSInteger index = [self.contents indexOfObject:item];
        if (index == NSNotFound) {
            return NSZeroRect;
        }

        NSRect iconRect = [self.outlineView frameOfCellAtColumn:0 row:index];

        // check that the icon rect is visible on screen
        NSRect visibleRect = [self.outlineView visibleRect];

        if (!NSIntersectsRect(visibleRect, iconRect)) {
            return NSZeroRect;
        }

        // convert icon rect to screen coordinates
        iconRect = [self.outlineView convertRectToBase:iconRect];
        iconRect.origin = [[self.outlineView window] convertBaseToScreen:iconRect.origin];

        return iconRect;
    }

// this delegate method provides a transition image between the table view and the preview panel
    - (id)previewPanel:(QLPreviewPanel *)panel transitionImageForPreviewItem:(id <QLPreviewItem>)item contentRect:(NSRect *)contentRect
    {
        return [[NSWorkspace sharedWorkspace] iconForFile:[item previewItemURL].path];
    }

- (IBAction)performFindPanelAction:(id)sender {
    [self.view.window makeFirstResponder:self.searchField];
}

@end
