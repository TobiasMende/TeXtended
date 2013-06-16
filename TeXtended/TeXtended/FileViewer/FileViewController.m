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
@implementation FileViewController

- (id)init {
    self = [self initWithNibName:@"FileView" bundle:nil];
    if (self) {
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    
    return self;
}

- (IBAction)openInfoView:(id)sender
{
    if(!self.doc)
        return;
    if(!self.doc.texPath)
        return;
    [self.infoWindowController showWindow:self.infoWindowController];
    [self.infoWindowController loadDocument:self.doc];
}

- (void)updateFileViewModel:(NSNotification*) notification
{
    if (!self.doc) {
        return;
    }
    
    if (!nodes) {
        return;
    }
    
    NSURL *url;
    if (self.doc.project)
        url = [NSURL fileURLWithPath:self.doc.project.path];
    else
        url = [NSURL fileURLWithPath:[self.doc.texPath stringByDeletingLastPathComponent]];
    [self loadPath:url];
}

- (void)doubleClick:(id)object {
    FileViewModel* model = (FileViewModel*)[outline itemAtRow:[outline clickedRow]];
    NSString *path = model.filePath;
    [self openFileInDefApp:path];
}

- (id)outlineView:(NSOutlineView *)outlineView
            child:(NSInteger)index
           ofItem:(id)item
{
    if(item == nil) {
        return [nodes getChildrenByIndex:index];
    }
    else {
        FileViewModel *model = (FileViewModel*)item;
        return [model getChildrenByIndex:index];
    }
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
   isItemExpandable:(id)item
{
    FileViewModel *model = (FileViewModel*)item;
    if([model numberOfChildren] > 0) return YES;
    
    return NO;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView
  numberOfChildrenOfItem:(id)item
{
    if(item == nil) {
        return [nodes numberOfChildren];
    }
    FileViewModel *model = (FileViewModel*)item;
    return [model numberOfChildren];
}

- (id)outlineView:(NSOutlineView *)outlineView
objectValueForTableColumn:(NSTableColumn *)tableColumn
           byItem:(id)item
{
    FileViewModel *model = (FileViewModel*)item;
    return model.fileName;
}

- (void)outlineView:(NSOutlineView *)outlineView
     setObjectValue:(id)object
     forTableColumn:(NSTableColumn *)tableColumn
             byItem:(id)item
{
    FileViewModel *model = (FileViewModel*)item;
    NSString* oldFile = [model filePath];
    NSString* newFile = (NSString*)object;
    [self renameFile:oldFile toNewFile:newFile];
    [model setFileName:oldFile toName:newFile];
    [outline reloadData];
    if(self.doc.project)
    {
        NSArray* docs = [self.doc.project.documents allObjects];
        for (NSInteger i = 0; i < [docs count]; i++) {
            DocumentModel *model = [docs objectAtIndex:i];
            if([model.texPath isEqualToString:oldFile])
                model.texPath = [[oldFile stringByDeletingLastPathComponent] stringByAppendingPathComponent:newFile];
        }
    }
    else
    {
        if([self.doc.texPath isEqualToString:oldFile])
        {
            self.doc.texPath = [[oldFile stringByDeletingLastPathComponent] stringByAppendingPathComponent:newFile];
            [self.titleButton setTitle:[newFile stringByDeletingPathExtension]];
        }
    }
}

- (void)    outlineView:(NSOutlineView *)outlineView
        willDisplayCell:(id)cell
         forTableColumn:(NSTableColumn *)tableColumn
                   item:(id)item
{
    FileViewModel *model = (FileViewModel*)item;
    CGFloat max = 17;
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

-(NSDragOperation) outlineView:(NSOutlineView *)outlineView validateDrop:(id<NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index
{
    if ([[info draggingPasteboard] availableTypeFromArray:[NSArray arrayWithObject:@"FileViewModel"]]) {
        return NSDragOperationMove;
    }
    if ([[info draggingPasteboard] availableTypeFromArray:[NSArray arrayWithObject:NSFilenamesPboardType]])
    {
        NSArray *draggedFilenames = [[info draggingPasteboard] propertyListForType:NSFilenamesPboardType];
        for(NSInteger i = 0; i < [draggedFilenames count]; i++)
            if(![[[draggedFilenames objectAtIndex:0] pathExtension] isEqualToString:@"tex"])
                return NSDragOperationNone;
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}

-(BOOL) outlineView:(NSOutlineView *)outlineView acceptDrop:(id<NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index
{
    if([[info draggingPasteboard] availableTypeFromArray:[NSArray arrayWithObject:NSFilenamesPboardType]])
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
    return TRUE;
}

-(BOOL) outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pasteboard
{
    [pasteboard declareTypes:[NSArray arrayWithObjects:@"FileViewModel", nil] owner:self];
    draggedItems = items;
    return YES;
}

-(void) outlineViewSelectionDidChange:(NSNotification *)notification
{
    FileViewModel* model = [outline itemAtRow:[outline selectedRow]];
    if(!model)
        return;
    if (![[model.fileName pathExtension] isEqualToString:@"tex"]) {
        return;
    }
    if(self.doc.project)
    {
        //TODO
    }
    else
    {
        if(![model.filePath isEqualToString:self.doc.texPath])
            [[DocumentCreationController sharedDocumentController] openDocumentWithContentsOfURL:[NSURL fileURLWithPath:model.filePath] display:YES error:nil];
    }
}

- (void) awakeFromNib {
    [super awakeFromNib];
    
    [self->outline setTarget:self];
    [self->outline setDelegate:self];
    [self->outline setDoubleAction:@selector(doubleClick:)];
    
    [[self titleLbl] setStringValue:@""];
    self.infoWindowController = [[InfoWindowController alloc] init];
    [outline registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, @"FileViewModel" , nil]];
}

- (void) recursiveFileFinder: (NSURL*)url
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSURL *directoryURL = url; // URL pointing to the directory you want to browse
    NSArray *keys = [NSArray arrayWithObject:NSURLIsDirectoryKey];
    
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
            [self->nodes addPath:path];
        }
        else
        {
            [self->nodes addPath:path];
            [self recursiveFileFinder:fileUrl];
        }
    }
}

- (BOOL)loadPath: (NSURL*)url
{
    nodes = [[FileViewModel alloc] init];
    [nodes setFilePath:[url path]];
    [self recursiveFileFinder:url];
    [outline reloadData];
    //[self initializeEventStream];
    return YES;
}

- (IBAction)newFile:(id)sender
{
    FileViewModel* model = [outline itemAtRow:[outline clickedRow]];
    if(!model)
        [self createFile:nodes.filePath];
    else
    {
        BOOL isDir;
        [[NSFileManager defaultManager] fileExistsAtPath:model.filePath isDirectory:&isDir];
        if(isDir)
            [self createFile:model.filePath];
        else
            [self createFile:[model.filePath stringByDeletingLastPathComponent]];
    }
}

- (IBAction)newFolder:(id)sender
{
    FileViewModel* model = [outline itemAtRow:[outline clickedRow]];
    if(!model)
        [self createFolder:nodes.filePath];
    else
    {
        BOOL isDir;
        [[NSFileManager defaultManager] fileExistsAtPath:model.filePath isDirectory:&isDir];
        if(isDir)
            [self createFolder:model.filePath];
        else
            [self createFolder:[model.filePath stringByDeletingLastPathComponent]];
    }
}

- (IBAction)duplicate:(id)sender
{
    FileViewModel* model = [outline itemAtRow:[outline clickedRow]];
    if(!model)
        return;
    [self duplicateFile:model.filePath];
    NSIndexSet* index = [NSIndexSet indexSetWithIndex:[outline clickedRow]];
    [outline selectRowIndexes:index byExtendingSelection:NO];
    [outline editColumn:[outline clickedColumn] row:[outline clickedRow] withEvent:nil select:YES];
}

- (IBAction)renameFile:(id)sender
{
    NSIndexSet* index = [NSIndexSet indexSetWithIndex:[outline clickedRow]];
    [outline selectRowIndexes:index byExtendingSelection:NO];
    [outline editColumn:[outline clickedColumn] row:[outline clickedRow] withEvent:nil select:YES];
}

- (IBAction)deleteFile:(id)sender
{
    FileViewModel* model = [outline itemAtRow:[outline clickedRow]];
    if(!model)
        return;
    [self deleteFileatPath:model.filePath];
    [model.parent removeChildren:model];
    [outline reloadData];
}

- (void) createFile:(NSString*)atPath
{
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

- (void) createFolder:(NSString*)atPath
{
    NSString* newPath = [atPath stringByAppendingPathComponent:@"New Folder"];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:newPath])
    {
        int counter = 2;
        while ([[NSFileManager defaultManager] fileExistsAtPath:newPath]) {
            newPath = [[newPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:[NSString stringWithFormat:@"New Folder (%d)", counter]];
            counter++;
        }
    }
    
    [[NSFileManager defaultManager] createDirectoryAtPath:newPath withIntermediateDirectories:NO attributes:nil error:nil];
    [nodes addPath:newPath];
    [outline reloadData];
}

- (void) duplicateFile:(NSString*)filePath
{
    NSString* fileName = [[filePath lastPathComponent] stringByDeletingPathExtension];
    NSString* fileExtension = [filePath pathExtension];
    NSString* path = [filePath stringByDeletingLastPathComponent];
    NSString* newPath = [NSString stringWithFormat:@"%@/%@ (copy).%@",path,fileName,fileExtension];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:newPath])
    {
        int counter = 2;
        while ([[NSFileManager defaultManager] fileExistsAtPath:newPath]) {
            newPath = [NSString stringWithFormat:@"%@/%@ (copy) (%d).%@",path,fileName,counter,fileExtension];
            counter++;
        }
    }
    
    [[NSFileManager defaultManager] copyItemAtPath:filePath toPath:newPath error:nil];
    [nodes addPath:newPath];
    [outline reloadData];
}

- (void) deleteFileatPath:(NSString*)path
{
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

- (IBAction)openFolderinFinder:(id)sender
{
    [self openFileInDefApp:nodes.filePath];
}

- (BOOL)openFileInDefApp: (NSString*)path
{
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    [workspace openFile:path];
    return YES;
}

- (void)renameFile:(NSString*)oldPath
         toNewFile:(NSString*)newFile {
    NSString *newPath = [[oldPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:newFile];
    [[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:newPath error:nil];
}

- (void)loadDocument:(DocumentModel*)document
{
    self.doc = document;
    NSString *totalPath;
    NSString *titleText;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    if (self.doc.project) {
        totalPath = self.doc.project.name;
        NSString *stringFromDate;
        if(self.doc.lastCompile)
        {
            stringFromDate = [formatter stringFromDate:self.doc.lastCompile];
            titleText = [NSString stringWithFormat:@"%@ - Last compile %@", _doc.project.name, stringFromDate];
        }
        else
            titleText = [NSString stringWithFormat:@"%@", _doc.project.name];
        
        // Add Oberserver
        NSArray *docs = [self.doc.project.documents allObjects];
        for(NSInteger i = 0; i < docs.count; i++)
            [[docs objectAtIndex:i] addObserver:self forKeyPath:@"texPath" options:0 context:NULL];
    } else {
        totalPath = self.doc.texPath;
        NSString *stringFromDate;
        if(self.doc.lastCompile)
        {
            stringFromDate = [formatter stringFromDate:self.doc.lastCompile];
            titleText = [NSString stringWithFormat:@"%@ - Last compile %@", _doc.texName.stringByDeletingPathExtension, stringFromDate];
        }
        else
            titleText = [NSString stringWithFormat:@"%@", _doc.texName.stringByDeletingPathExtension];
        
        // Add Observer
        [self.doc addObserver:self forKeyPath:@"texPath" options:0 context:NULL];
    }
    
    // In Sandboxmode
    if([titleText isEqualToString:@"(null)"])
    {
        [self.titleButton setTitle:@""];
        return;
    }
    [self.titleButton setTitle:titleText];
    if(!totalPath ||[totalPath length] == 0)
        return;
    
    // Load Path in FileView
    NSString *path = [totalPath stringByDeletingLastPathComponent];
    //NSString* path = @"/Users/Tobias/Documents/LatexDummies";
    NSURL *url = [NSURL fileURLWithPath:path];
    @try {
        [self loadPath:url];
    }
    @catch (NSException *exception) {
        [self.titleButton setTitle:@""];
        [self.titleButton setEnabled:FALSE];
    }
    @finally {
        return;
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                       change:(NSDictionary *)change context:(void*)context {
    DocumentModel *dc = (DocumentModel*)object;
    //NSLog(@"Pfad geändert: %@ zu %@", [change valueForKey:NSKeyValueChangeOldKey], [change valueForKey:NSKeyValueChangeNewKey]);
    NSLog(@"Pfad geändert: %@ zu %@", [change valueForKey:NSKeyValueChangeOldKey], dc.texPath);
    if (!nodes && ![dc.texPath isEqualToString:@"(null)"]) {
        //[self updateFileViewModel:nil];
    }
}

- (void)moveFile:(NSString*)oldPath
          toPath:(NSString*)newPath
   withinProject:(BOOL)within
{
    if([[NSFileManager defaultManager] isReadableFileAtPath:oldPath])
    {
        [[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:newPath error:nil];
        if (!within) {
            [nodes addPath:newPath];
            [outline reloadData];
        }
    }
}

-(void) setDocController:(DocumentController *)docController
{
    if(_docController)
        [[NSNotificationCenter defaultCenter] removeObserver:self name:TMTCompilerDidEndCompiling object:nil];
    [self willChangeValueForKey:@"docController"];
    _docController = docController;
    [self didChangeValueForKey:@"docController"];
    for (DocumentModel* model in self.doc.mainDocuments) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFileViewModel:) name:TMTCompilerDidEndCompiling object:model];
    }
}

- (void)dealloc {
    if (self.doc.project)
    {
        NSArray *docs = [self.doc.project.documents allObjects];
        for(NSInteger i = 0; i < docs.count; i++)
            [[docs objectAtIndex:i] removeObserver:self forKeyPath:@"texPath"];
    }
    else
        [self.doc removeObserver:self forKeyPath:@"texPath"];
    if (self.docController) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
#ifdef DEBUG
    NSLog(@"FileViewController dealloc");
#endif
}

@end
