//
//  OutlineViewStaticAppDeligate.m
//  Sandbox
//
//  Created by Tobias Hecht on 16.04.13.
//  Copyright (c) 2013 Tobias Hecht. All rights reserved.
//

#import "FileViewController.h"
#import "DocumentModel.h"
#import "ProjectModel.h"
#import "InfoWindowController.h"
#import "FileViewModel.h"
#import "DocumentController.h"
#import "DocumentCreationController.h"
#import "Constants.h"
#import "PathObserverFactory.h"

@implementation FileViewController

- (id)init {
    self = [super initWithNibName:@"FileView" bundle:nil];
    if (self) {
    }
    return self;
}

- (void)setDocument:(DocumentModel *)document {
    if (document != _document) {
        if (_document) {
            [self.document removeObserver:self forKeyPath:@"self.mainCompilable.path"];
        }
        _document = document;
        if (_document) {
            [self.document addObserver:self forKeyPath:@"self.mainCompilable.path" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
        }
    }
}


-(void)loadView {
    [super loadView];
    self.infoWindowController = [[InfoWindowController alloc] init];
    [outline registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, @"FileViewModel" , nil]];
    [outline setTarget:self];
    [outline setDoubleAction:@selector(doubleClick:)];
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
        if (children.isDir) {
            if (!children.expandable) {
                [self simpleFileFinder:[NSURL fileURLWithPath:children.filePath]];
            }
        }
        return children;
    }
    else {
        FileViewModel *model = (FileViewModel*)item;
        FileViewModel* children = [model getChildrenByIndex:index];
        if (children.isDir) {
            if (!children.expandable) {
                [self simpleFileFinder:[NSURL fileURLWithPath:children.filePath]];
            }
        }
        return [model getChildrenByIndex:index];
    }
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
   isItemExpandable:(id)item {
    FileViewModel *model = (FileViewModel*)item;
    if([model numberOfChildren] > 0)
    {
        return YES;
    }
    
    return NO;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView
  numberOfChildrenOfItem:(id)item {
    if(item == nil) {
        return [nodes numberOfChildren];
    }
    FileViewModel *model = (FileViewModel*)item;
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
    [self renameFile:oldFile toNewFile:newFile];
    [model setFileName:oldFile toName:newFile];
    [outline reloadData];
    
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
    if ([[info draggingPasteboard] availableTypeFromArray:[NSArray arrayWithObject:@"FileViewModel"]]) {
        return NSDragOperationMove;
    }
    if ([[info draggingPasteboard] availableTypeFromArray:[NSArray arrayWithObject:NSFilenamesPboardType]])
    {
        NSArray *draggedFilenames = [[info draggingPasteboard] propertyListForType:NSFilenamesPboardType];
        for(NSInteger i = 0; i < [draggedFilenames count]; i++)
        {
            if(![[[draggedFilenames objectAtIndex:0] pathExtension] isEqualToString:@"tex"])
            {
                return NSDragOperationNone;
            }
        }
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}

-(BOOL) outlineView:(NSOutlineView *)outlineView acceptDrop:(id<NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index {
    if([[info draggingPasteboard] availableTypeFromArray:[NSArray arrayWithObject:@"FileViewModel"]])
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
                    FileViewModel* moved = (FileViewModel*)[draggedItems objectAtIndex:i];
                    [self moveFile:moved.filePath toPath:[model.filePath stringByAppendingPathComponent:moved.fileName] withinProject:YES];
                    [model addExitsingChildren:moved];
                }
            }
            else
            {
                for(NSInteger i = 0; i < [draggedItems count]; i++)
                {
                    FileViewModel* moved = (FileViewModel*)[draggedItems objectAtIndex:i];
                    [self moveFile:moved.filePath toPath:[model.parent.filePath stringByAppendingPathComponent:moved.fileName] withinProject:YES];
                    [model.parent addExitsingChildren:moved];
                }
            }
        }
        else
        {
            for(NSInteger i = 0; i < [draggedItems count]; i++)
            {
                FileViewModel* moved = (FileViewModel*)[draggedItems objectAtIndex:i];
                [self moveFile:moved.filePath toPath:[nodes.filePath stringByAppendingPathComponent:moved.fileName] withinProject:YES];
                [nodes addExitsingChildren:moved];
            }
        }
        [outline reloadData];
    }
    else if([[info draggingPasteboard] availableTypeFromArray:[NSArray arrayWithObject:NSFilenamesPboardType]])
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
                    NSString* newPath = [model.filePath stringByAppendingPathComponent:[[draggedFilenames   objectAtIndex:i] lastPathComponent]];
                    [self moveFile:[draggedFilenames objectAtIndex:i] toPath:newPath withinProject:NO];
                }
            }
            else
            {
                for(NSInteger i = 0; i < [draggedFilenames count]; i++)
                {
                    NSString* newPath = [[model.filePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:[[draggedFilenames objectAtIndex:i] lastPathComponent]];
                    [self moveFile:[draggedFilenames objectAtIndex:i] toPath:newPath withinProject:NO];
                }
            }
        }
        else
        {
            NSArray *draggedFilenames = [[info draggingPasteboard] propertyListForType:NSFilenamesPboardType];
            for(NSInteger i = 0; i < [draggedFilenames count]; i++)
            {
                NSString* newPath = [nodes.filePath stringByAppendingPathComponent:[[draggedFilenames objectAtIndex:i] lastPathComponent]];
                [self moveFile:[draggedFilenames objectAtIndex:i] toPath:newPath withinProject:NO];
            }
        }
    }
    return TRUE;
}

-(BOOL) outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pasteboard {
    [pasteboard declareTypes:[NSArray arrayWithObjects:@"FileViewModel", nil] owner:self];
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:[items count]];
    for (FileViewModel* item in items)
    {
        [array addObject:item.filePath];
    }
    [pasteboard setPropertyList:array forType:NSFilenamesPboardType];
    draggedItems = items;
    return YES;
}

/*-(void) outlineViewSelectionDidChange:(NSNotification *)notification {
    FileViewModel* model = [outline itemAtRow:[outline selectedRow]];
    if(!model)
    {
        return;
    }
    
    if (![[model.fileName pathExtension] isEqualToString:@"tex"]) {
        return;
    }
    if(self.document.project)
    {
        //TODO
    }
    else
    {
        if(![model.filePath isEqualToString:self.document.texPath])
        {
            [[DocumentCreationController sharedDocumentController] openDocumentWithContentsOfURL:[NSURL fileURLWithPath:model.filePath] display:YES error:nil];
        }
    }
}*/

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
    NSArray *keys = [NSArray arrayWithObject:NSURLIsDirectoryKey];
    NSArray *ignoredFileTypes = [NSArray arrayWithObjects:@"TMTTemporaryStorage", nil];
    
    NSArray *children = [[NSArray alloc] initWithArray:[fileManager contentsOfDirectoryAtURL:directoryURL includingPropertiesForKeys:keys options:NSDirectoryEnumerationSkipsHiddenFiles error:NULL]];
    NSUInteger count = [children count];
    
    for (NSUInteger i = 0; i < count; i++) {
        NSError *error;
        NSNumber *isDirectory = nil;
        NSURL *fileUrl = [children objectAtIndex:i];
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
            // For recursiveFileFinder:
            //[self recursiveFileFinder:fileUrl];
        }
    }
}

- (void) recursiveFileUpdater: (NSURL*)url {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSURL *directoryURL = url; // URL pointing to the directory you want to browse
    NSArray *keys = [NSArray arrayWithObject:NSURLIsDirectoryKey];
    NSArray *ignoredFileTypes = [NSArray arrayWithObjects:@"TMTTemporaryStorage", nil];
    
    NSArray *children = [[NSArray alloc] initWithArray:[fileManager contentsOfDirectoryAtURL:directoryURL includingPropertiesForKeys:keys options:NSDirectoryEnumerationSkipsHiddenFiles error:NULL]];
    NSUInteger count = [children count];
    
    for (NSUInteger i = 0; i < count; i++) {
        NSError *error;
        NSNumber *isDirectory = nil;
        NSURL *fileUrl = [children objectAtIndex:i];
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
            if ([self->nodes expandableAtPath:path]) {
                [self recursiveFileUpdater:fileUrl];
            }
        }
    }
    [self->nodes clean];
}

- (IBAction)openInfoView:(id)sender {
    if(!self.document)
    {
        return;
    }
    if(!self.document.texPath)
    {
        return;
    }
    [self.infoWindowController showWindow:self.infoWindowController];
    self.infoWindowController.doc = self.document;
}

- (IBAction)newFile:(id)sender {
    FileViewModel* model = [outline itemAtRow:[outline clickedRow]];
    if(!model)
    {
        [self createFile:nodes.filePath];
    }
    else
    {
        BOOL isDir;
        [[NSFileManager defaultManager] fileExistsAtPath:model.filePath isDirectory:&isDir];
        if(isDir)
        {
            [self createFile:model.filePath];
        }
        else
        {
            [self createFile:[model.filePath stringByDeletingLastPathComponent]];
        }
    }
}

- (IBAction)newFolder:(id)sender {
    FileViewModel* model = [outline itemAtRow:[outline clickedRow]];
    if(!model)
        [self createFolder:nodes.filePath];
    else
    {
        BOOL isDir;
        [[NSFileManager defaultManager] fileExistsAtPath:model.filePath isDirectory:&isDir];
        if(isDir)
        {
            [self createFolder:model.filePath];
        }
        else
        {
            [self createFolder:[model.filePath stringByDeletingLastPathComponent]];
        }
    }
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
    NSLog(@"renameProject not implemented yet...");
}

- (IBAction)closeProject:(id)sender {
    NSLog(@"closeProject not implemented yet...");
}

- (IBAction)openFile:(id)sender {
    FileViewModel* model = [outline itemAtRow:[outline clickedRow]];
    if(!model) {
        return;
    }
    [self openFileInDefApp:model.filePath];
}

- (IBAction)openInfoViewForFile:(id)sender {
    NSLog(@"openInfoViewForFile not implemented yet...");
}

- (void) createFile:(NSString*)atPath {
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
    [nodes addPath:newPath];
    [outline reloadData];
}

- (void) createFolder:(NSString*)atPath {
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
    [nodes addPath:newPath];
    [outline reloadData];
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
    NSArray *allowedFileTypes = [NSArray arrayWithObjects:@"tex", nil];
    NSLog(@"%@ - %@", path, self.document.mainCompilable.path);
    if ([allowedFileTypes containsObject:[path pathExtension]]) {
        if(![path isEqualToString:self.document.mainCompilable.path]) {
            [[DocumentCreationController sharedDocumentController] openDocumentWithContentsOfURL:[NSURL fileURLWithPath:path] display:YES error:nil];
        }
        return;
    }
    else {
        NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
        [workspace openFile:path];
    }
}

- (void)renameFile:(NSString*)oldPath
         toNewFile:(NSString*)newFile {
    NSString *newPath = [[oldPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:newFile];
    [[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:newPath error:nil];
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
    if ([keyPath isEqualToString:@"self.mainCompilable.path"]) {
        if (!self.document.mainCompilable.path) {
            return;
        }
        
        if (observer) {
            [PathObserverFactory removeObserver:self];
        }
        NSString *path = [self.document.mainCompilable.path stringByDeletingLastPathComponent];
        observer = [PathObserverFactory pathObserverForPath:path];
        [self loadPath:[NSURL fileURLWithPath:path]];
        [observer addObserver:self withSelector:@selector(updateFileViewModel)];
    }
    
}

- (void)updateFileViewModel {
    if (!self.document.mainCompilable.path) {
        return;
    }
    
    if (![outline editedColumn]) {
        return;
    }
    
    NSURL *url  = [NSURL fileURLWithPath:[self.document.mainCompilable.path stringByDeletingLastPathComponent]];
    [self recursiveFileUpdater:url];
    [outline reloadData];
}


- (void)dealloc {
    [PathObserverFactory removeObserver:self];
    [self.document removeObserver:self forKeyPath:@"self.mainCompilable.path"];
#ifdef DEBUG
    NSLog(@"FileViewController dealloc");
#endif
}

@end
