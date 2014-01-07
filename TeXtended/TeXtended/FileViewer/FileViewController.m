
//
//  OutlineViewStaticAppDeligate.m
//  Sandbox
//
//  Created by Tobias Hecht on 16.04.13.
//  Copyright (c) 2013 Tobias Hecht. All rights reserved.
//

#import "FileViewController.h"
#import "DocumentModel.h"
#import "Compilable.h"
#import "ProjectModel.h"
#import "InfoWindowController.h"
#import "FileViewModel.h"
#import "DocumentController.h"
#import "DocumentCreationController.h"
#import "Constants.h"
#import <TMTHelperCollection/PathObserverFactory.h>
#import <TMTHelperCollection/TMTLog.h>
#import "ProjectDocument.h"
#import "SimpleDocument.h"

@implementation FileViewController

- (id)init {
    self = [super initWithNibName:@"FileView" bundle:nil];
    if (self) {
    }
    return self;
}

- (void)setCompilable:(Compilable *)compilable {
    if (compilable != _compilable) {
        if (_compilable) {
            [_compilable removeObserver:self forKeyPath:@"self.path"];
        }
        _compilable = compilable;
        self.infoWindowController.compilable = compilable;
        if (_compilable) {
            [self.compilable addObserver:self forKeyPath:@"self.path" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:NULL];
        }
    }
}

-(void)loadView {
    [super loadView];
    self.infoWindowController = [[InfoWindowController alloc] init];
    self.infoWindowController.compilable = self.compilable;
    [outline registerForDraggedTypes:@[NSFilenamesPboardType, @"FileViewModel"]];
    [outline setTarget:self];
    [outline setDoubleAction:@selector(doubleClick:)];
    
    [self.infoWindowController addObserver:self forKeyPath:@"self.window.isVisible" options:0 context:nil];
}

- (IBAction)doubleClick:(id)sender {
    FileViewModel* model = (FileViewModel*)[outline itemAtRow:[outline clickedRow]];
    if (!model) {
        return;
    }
    [self openFileInDefApp:model.filePath];
}

- (id)outlineView:(NSOutlineView *)outlineView
            child:(NSInteger)index
           ofItem:(id)item {
    if(item == nil) {
        FileViewModel* children = [nodes getChildrenByIndex:index];
        return children;
    }
    else {
        FileViewModel *model = (FileViewModel*)item;
        if ([model isDir]) {
            if (!model.expandable) {
                [self simpleFileFinder:[NSURL fileURLWithPath:model.filePath]];
            }
        }
        FileViewModel* children = [model getChildrenByIndex:index];
        return children;
    }
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
   isItemExpandable:(id)item {
    FileViewModel *model = (FileViewModel*)item;
    return [model isDir];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView
  numberOfChildrenOfItem:(id)item {
    if(item == nil) {
        return [nodes numberOfChildren];
    }
    FileViewModel *model = (FileViewModel*)item;
    if ([model isDir]) {
        if (!model.expandable) {
            [self simpleFileFinder:[NSURL fileURLWithPath:model.filePath]];
        }
    }
    return [model numberOfChildren];
}

- (id)outlineView:(NSOutlineView *)outlineView
objectValueForTableColumn:(NSTableColumn *)tableColumn
           byItem:(id)item {
    FileViewModel *model = (FileViewModel*)item;
    return model.fileName;
}

- (void)outlineView:(NSOutlineView *)outlineView
     setObjectValue:(id)object
     forTableColumn:(NSTableColumn *)tableColumn
             byItem:(id)item {
    FileViewModel *model = (FileViewModel*)item;
    NSString* oldFile = [model filePath];
    NSString* newFile = (NSString*)object;
    if([self renameFile:oldFile toNewFile:newFile])
    {
        [model setFileName:oldFile toName:newFile];
        [outline reloadData];
        [outline selectRowIndexes:[NSIndexSet indexSetWithIndex:[outline rowForItem:item]] byExtendingSelection:NO];
    }
    else
    {
        // Errormessage?
    }
}

- (void)    outlineView:(NSOutlineView *)outlineView
        willDisplayCell:(id)cell
         forTableColumn:(NSTableColumn *)tableColumn
                   item:(id)item {
    FileViewModel *model = (FileViewModel*)item;
    CGFloat max = 12;
    CGFloat scale = 0;
    NSImage *img = model.icon;
    NSSize size = NSZeroSize;
    if(img.size.width > img.size.height)
    {
        scale = img.size.height/img.size.width;
        size.width = max;
        size.height = scale*max;
    }
    else
    {
        scale = img.size.width/img.size.height;
        size.height = max;
        size.width = scale*max;
    }
    
    [img setSize:size];
    [cell setImage:img];
}

-(NSDragOperation) outlineView:(NSOutlineView *)outlineView validateDrop:(id<NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index {
    if ([[info draggingPasteboard] availableTypeFromArray:@[@"FileViewModel"]]) {
        return NSDragOperationMove;
    }
    if ([[info draggingPasteboard] availableTypeFromArray:@[NSFilenamesPboardType]])
    {
        NSArray *draggedFilenames = [[info draggingPasteboard] propertyListForType:NSFilenamesPboardType];
        for(NSInteger i = 0; i < [draggedFilenames count]; i++)
        {
            if(![[draggedFilenames[0] pathExtension] isEqualToString:@"tex"])
            {
                return NSDragOperationNone;
            }
        }
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}

-(BOOL) outlineView:(NSOutlineView *)outlineView acceptDrop:(id<NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index {
    if([[info draggingPasteboard] availableTypeFromArray:@[@"FileViewModel"]])
    {
        if(item)
        {
            FileViewModel *model = (FileViewModel*)item;
            BOOL b = false;
            [[NSFileManager defaultManager] fileExistsAtPath:model.filePath isDirectory:&b];
            if(b)
            {
                for(NSInteger i = 0; i < [draggedItems count]; i++)
                {
                    FileViewModel* moved = (FileViewModel*)draggedItems[i];
                    [self moveFile:moved.filePath toPath:[model.filePath stringByAppendingPathComponent:moved.fileName] withinProject:YES];
                    [model addExitsingChildren:moved];
                }
            }
            else
            {
                for(NSInteger i = 0; i < [draggedItems count]; i++)
                {
                    FileViewModel* moved = (FileViewModel*)draggedItems[i];
                    [self moveFile:moved.filePath toPath:[model.parent.filePath stringByAppendingPathComponent:moved.fileName] withinProject:YES];
                    [model.parent addExitsingChildren:moved];
                }
            }
        }
        else
        {
            for(NSInteger i = 0; i < [draggedItems count]; i++)
            {
                FileViewModel* moved = (FileViewModel*)draggedItems[i];
                [self moveFile:moved.filePath toPath:[nodes.filePath stringByAppendingPathComponent:moved.fileName] withinProject:YES];
                [nodes addExitsingChildren:moved];
            }
        }
        [outline reloadData];
    }
    else if([[info draggingPasteboard] availableTypeFromArray:@[NSFilenamesPboardType]])
    {
        if(item)
        {
            NSArray *draggedFilenames = [[info draggingPasteboard] propertyListForType:NSFilenamesPboardType];
            FileViewModel *model = (FileViewModel*)item;
            BOOL b = false;
            [[NSFileManager defaultManager] fileExistsAtPath:model.filePath isDirectory:&b];
            if(b)
            {
                for(NSInteger i = 0; i < [draggedFilenames count]; i++)
                {
                    NSString* newPath = [model.filePath stringByAppendingPathComponent:[draggedFilenames[i] lastPathComponent]];
                    [self moveFile:draggedFilenames[i] toPath:newPath withinProject:NO];
                }
            }
            else
            {
                for(NSInteger i = 0; i < [draggedFilenames count]; i++)
                {
                    NSString* newPath = [[model.filePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:[draggedFilenames[i] lastPathComponent]];
                    [self moveFile:draggedFilenames[i] toPath:newPath withinProject:NO];
                }
            }
        }
        else
        {
            NSArray *draggedFilenames = [[info draggingPasteboard] propertyListForType:NSFilenamesPboardType];
            for(NSInteger i = 0; i < [draggedFilenames count]; i++)
            {
                NSString* newPath = [nodes.filePath stringByAppendingPathComponent:[draggedFilenames[i] lastPathComponent]];
                [self moveFile:draggedFilenames[i] toPath:newPath withinProject:NO];
            }
        }
    }
    return TRUE;
}

-(BOOL) outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pasteboard {
    [pasteboard declareTypes:@[@"FileViewModel"] owner:self];
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:[items count]];
    for (FileViewModel* item in items)
    {
        [array addObject:item.filePath];
    }
    [pasteboard setPropertyList:array forType:NSFilenamesPboardType];
    draggedItems = items;
    return YES;
}

- (BOOL)loadPath: (NSURL*)url {
    nodes = [[FileViewModel alloc] init];
    [nodes setFilePath:[url path]];
    @try {
        [self simpleFileFinder:url];
        [outline reloadData];
    }
    @catch (NSException *exception) {
        /*
         * In the "revert to" functionallity the texPath is systematically wrong.
         */
        return NO;
    }
    return YES;
}


- (void) simpleFileFinder: (NSURL*)url {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSURL *directoryURL = url; // URL pointing to the directory you want to browse
    NSArray *keys = @[NSURLIsDirectoryKey];
    NSArray *ignoredFileTypes = @[@"TMTTemporaryStorage"];
    
    NSArray *children = [[NSArray alloc] initWithArray:[fileManager contentsOfDirectoryAtURL:directoryURL includingPropertiesForKeys:keys options:NSDirectoryEnumerationSkipsHiddenFiles error:NULL]];
    NSUInteger count = [children count];
    
    for (NSUInteger i = 0; i < count; i++) {
        NSError *error;
        NSNumber *isDirectory = nil;
        NSURL *fileUrl = children[i];
        NSString *path = [fileUrl path];
        if (! [fileUrl getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error]) {
            // handle error
        }
        else if (! [isDirectory boolValue]) {
            if (![ignoredFileTypes containsObject:[path pathExtension]]) {
                [self->nodes addPath:path];
            }
        }
        else
        {
            [self->nodes addPath:path];
        }
    }
}

- (void) fileUpdater: (NSURL*)url {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSURL *directoryURL = url; // URL pointing to the directory you want to browse
    NSArray *keys = @[NSURLIsDirectoryKey];
    NSArray *ignoredFileTypes = @[@"TMTTemporaryStorage"];
    
    NSArray *children = [[NSArray alloc] initWithArray:[fileManager contentsOfDirectoryAtURL:directoryURL includingPropertiesForKeys:keys options:NSDirectoryEnumerationSkipsHiddenFiles error:NULL]];
    NSUInteger count = [children count];
    
    for (NSUInteger i = 0; i < count; i++) {
        NSError *error;
        NSNumber *isDirectory = nil;
        NSURL *fileUrl = children[i];
        NSString *path = [fileUrl path];
        if (! [fileUrl getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error]) {
            // handle error
        }
        else if (! [isDirectory boolValue]) {
            if (![ignoredFileTypes containsObject:[path pathExtension]]) {
                [self->nodes addPath:path];
            }
        }
        else
        {
            [self->nodes addPath:path];
        }
    }
    [self->nodes clean:[url path]];
}

- (IBAction)newFile:(id)sender {
    FileViewModel* model = [outline itemAtRow:[outline clickedRow]];
    FileViewModel* newModel;
    if(!model)
    {
        newModel = [self createFile:nodes.filePath];
    }
    else
    {
        BOOL isDir;
        [[NSFileManager defaultManager] fileExistsAtPath:model.filePath isDirectory:&isDir];
        if(isDir)
        {
            newModel = [self createFile:model.filePath];
        }
        else
        {
            newModel = [self createFile:[model.filePath stringByDeletingLastPathComponent]];
        }
    }
    
    NSInteger i = [outline rowForItem:newModel];
    [outline selectRowIndexes:[NSIndexSet indexSetWithIndex:i] byExtendingSelection:NO];
    [outline editColumn:[outline clickedColumn] row:i withEvent:nil select:YES];
}

- (IBAction)newFolder:(id)sender {
    FileViewModel* model = [outline itemAtRow:[outline clickedRow]];
    FileViewModel* newModel;
    if(!model)
        newModel = [self createFolder:nodes.filePath];
    else
    {
        BOOL isDir;
        [[NSFileManager defaultManager] fileExistsAtPath:model.filePath isDirectory:&isDir];
        if(isDir)
        {
            newModel = [self createFolder:model.filePath];
        }
        else
        {
            newModel = [self createFolder:[model.filePath stringByDeletingLastPathComponent]];
        }
    }
    
    NSInteger i = [outline rowForItem:newModel];
    [outline selectRowIndexes:[NSIndexSet indexSetWithIndex:i] byExtendingSelection:NO];
    [outline editColumn:[outline clickedColumn] row:i withEvent:nil select:YES];
}

- (IBAction)duplicate:(id)sender {
    FileViewModel* model = [outline itemAtRow:[outline clickedRow]];
    if(!model)
        return;
    FileViewModel* duplicate = [self duplicateFile:model.filePath];
    NSInteger i = [outline rowForItem:duplicate];
    [outline selectRowIndexes:[NSIndexSet indexSetWithIndex:i] byExtendingSelection:NO];
    [outline editColumn:[outline clickedColumn] row:i withEvent:nil select:YES];
}

- (IBAction)renameFile:(id)sender {
    [outline selectRowIndexes:[NSIndexSet indexSetWithIndex:[outline clickedRow]] byExtendingSelection:NO];
    [outline editColumn:[outline clickedColumn] row:[outline clickedRow] withEvent:nil select:YES];
}

- (IBAction)deleteFile:(id)sender {
    FileViewModel* model = [outline itemAtRow:[outline clickedRow]];
    if(!model)
        return;
    [self deleteFileatPath:model.filePath];
    [model.parent removeChildren:model];
    [outline reloadData];
}

- (IBAction)openFolderinFinder:(id)sender {
    [self openFileInDefApp:nodes.filePath];
}

- (IBAction)renameProject:(id)sender {
    DDLogError(@"renameProject not implemented yet...");
}

- (IBAction)closeProject:(id)sender {
    DDLogError(@"closeProject not implemented yet...");
}

- (IBAction)openFile:(id)sender {
    FileViewModel* model = [outline itemAtRow:[outline clickedRow]];
    if(!model) {
        return;
    }
    [self openFileInDefApp:model.filePath];
}

- (IBAction)openInfoViewForFile:(id)sender {
    self.infoWindowController.window.isVisible = YES;
}

- (IBAction)showInformationForFile:(id)sender {
    FileViewModel* model = [outline itemAtRow:[outline clickedRow]];
    if(!model)
        return;
    self.infoWindowController.compilable = [self.compilable modelForTexPath:model.filePath];
    self.infoWindowController.window.isVisible = YES;
}

- (FileViewModel*) createFile:(NSString*)atPath {
    NSString* newPath = [atPath stringByAppendingPathComponent:@"New File.tex"];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:newPath])
    {
        int counter = 2;
        while ([[NSFileManager defaultManager] fileExistsAtPath:newPath]) {
            newPath = [[newPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:[NSString stringWithFormat:@"New File (%d).tex", counter]];
            counter++;
        }
    }
    
    [[NSFileManager defaultManager] createFileAtPath:newPath contents:nil attributes:nil];
    FileViewModel* newModel = [nodes addPath:newPath];
    [outline reloadData];
    return newModel;
}

- (FileViewModel*) createFolder:(NSString*)atPath {
    NSString* newPath = [atPath stringByAppendingPathComponent:NSLocalizedString(@"New Folder", @"New Folder")];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:newPath])
    {
        int counter = 2;
        while ([[NSFileManager defaultManager] fileExistsAtPath:newPath]) {
            newPath = [[newPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:[NSString stringWithFormat:NSLocalizedString(@"New Folder (%d)", @"New Folder with counter"), counter]];
            counter++;
        }
    }
    
    [[NSFileManager defaultManager] createDirectoryAtPath:newPath withIntermediateDirectories:NO attributes:nil error:nil];
    FileViewModel* newModel = [nodes addPath:newPath];
    [outline reloadData];
    return newModel;
}

- (FileViewModel*) duplicateFile:(NSString*)filePath {
    NSString* fileName = [[filePath lastPathComponent] stringByDeletingPathExtension];
    NSString* fileExtension = [filePath pathExtension];
    NSString* path = [filePath stringByDeletingLastPathComponent];
    NSString* newPath = [NSString stringWithFormat:NSLocalizedString(@"%@/%@ (copy).%@", @"copied file name"),path,fileName,fileExtension];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:newPath])
    {
        int counter = 2;
        while ([[NSFileManager defaultManager] fileExistsAtPath:newPath]) {
            newPath = [NSString stringWithFormat:NSLocalizedString(@"%@/%@ (copy) (%d).%@", @"copied file name with counter"),path,fileName,counter,fileExtension];
            counter++;
        }
    }
    
    [[NSFileManager defaultManager] copyItemAtPath:filePath toPath:newPath error:nil];
    FileViewModel* model = [nodes addPath:newPath];
    [outline reloadData];
    return model;
}

- (void) deleteFileatPath:(NSString*)path {
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

- (void)openFileInDefApp: (NSString*)path {
    NSArray *allowedFileTypes = @[@"tex", @"sty", @"cls"];
    DDLogInfo(@"%@ - %@", path, self.compilable.path);
    if ([allowedFileTypes containsObject:[path pathExtension]]) {
        [[DocumentCreationController sharedDocumentController] showTexDocumentForPath:path withReferenceModel:self.compilable andCompletionHandler:nil];
    }
    else {
        NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
        [workspace openFile:path];
    }
}

- (BOOL)renameFile:(NSString*)oldPath
         toNewFile:(NSString*)newFile {
    NSString *newPath = [[oldPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:newFile];
    return [[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:newPath error:nil];
}

- (void)moveFile:(NSString*)oldPath
          toPath:(NSString*)newPath
   withinProject:(BOOL)within {
    if([[NSFileManager defaultManager] isReadableFileAtPath:oldPath])
    {
        [[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:newPath error:nil];
        if (!within) {
            [nodes addPath:newPath];
            [outline reloadData];
        }
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                       change:(NSDictionary *)change context:(void*)context {
    if ([keyPath isEqualToString:@"self.path"]) {
        if (!self.compilable.path) {
            return;
        }
        
        if (change[NSKeyValueChangeOldKey] == [NSNull null]) {
            return;
        }
        
        if ([change[NSKeyValueChangeOldKey] isEqualToString:change[NSKeyValueChangeNewKey]]) {
            // If the path did not change, there is no need to remove pathobserver
            return;
        }
        
        if (observer) {
            [PathObserverFactory removeObserver:self];
        }
        NSString *path = [self.compilable.path stringByDeletingLastPathComponent];
        observer = [PathObserverFactory pathObserverForPath:path];
        [self loadPath:[NSURL fileURLWithPath:path]];
        [observer addObserver:self withSelector:@selector(updateFileViewModel:)];
    }
    else if ([keyPath isEqualToString:@"self.window.isVisible"]) {
        if (!self.infoWindowController.window.isVisible) {
            self.infoWindowController.compilable = self.compilable;
        }
    }
    
}

- (void)updateFileViewModel:(NSArray *)affectedPaths {
    if (!self.compilable.path) {
        return;
    }
    
    if (![outline editedColumn]) {
        return;
    }
    
    for (NSString* path in affectedPaths) {
        if([path hasPrefix:[self.compilable.path stringByDeletingLastPathComponent]]) {
            NSURL *url  = [NSURL fileURLWithPath:path];
            [self fileUpdater:url];
        }
    }
    [outline reloadData];
}

- (void)deleteTemporaryFilesAtPath:(NSString*)path
{
    NSArray *temporaryFileTypes = [[NSArray alloc] initWithObjects:@"aux", @"synctex", @"gz",@"gz(busy)",@"log", @"bbl", nil];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSURL *directoryURL = [[NSURL alloc] initFileURLWithPath:path]; // URL pointing to the directory you want to browse
    NSArray *keys = @[NSURLIsDirectoryKey];
    
    NSArray *children = [[NSArray alloc] initWithArray:[fileManager contentsOfDirectoryAtURL:directoryURL includingPropertiesForKeys:keys options:NSDirectoryEnumerationSkipsHiddenFiles error:NULL]];
    NSUInteger count = [children count];
    
    for (NSUInteger i = 0; i < count; i++) {
        NSError *error;
        NSNumber *isDirectory = nil;
        NSURL *fileUrl = children[i];
        NSString *filePath = [fileUrl path];
        if (! [fileUrl getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error]) {
            // handle error
        }
        else if (! [isDirectory boolValue]) {
            if ([temporaryFileTypes containsObject:[filePath pathExtension]]) {
                [self deleteFileatPath:filePath];
            }
        }
    }
    
    [nodes clean:path];
}

- (void)dealloc {
    [PathObserverFactory removeObserver:self];
    [self.compilable removeObserver:self forKeyPath:@"self.path"];
    [self.infoWindowController removeObserver:self forKeyPath:@"self.window.isVisible"];
    DDLogVerbose(@"dealloc");
}

@end
