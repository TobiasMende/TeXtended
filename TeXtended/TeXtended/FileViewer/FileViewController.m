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
        self.doc.texPath = [[oldFile stringByDeletingLastPathComponent] stringByAppendingPathComponent:newFile];
        [self.titleButton setTitle:[newFile stringByDeletingPathExtension]];
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

- (void) awakeFromNib {
    [super awakeFromNib];
    
    [self->outline setTarget:self];
    [self->outline setDelegate:self];
    [self->outline setDoubleAction:@selector(doubleClick:)];
    
    pathsToWatch = [[NSMutableArray alloc] init];
    nodes = [[FileViewModel alloc] init];
    [[self titleLbl] setStringValue:@""];
    self.infoWindowController = [[InfoWindowController alloc] init];
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
            [pathsToWatch addObject:path];
            [self recursiveFileFinder:fileUrl];
        }
    }
}

- (BOOL)loadPath: (NSURL*)url
{
    [pathsToWatch removeAllObjects];
    [nodes setFilePath:[url path]];
    [self recursiveFileFinder:url];
    [outline reloadData];
    //NSLog(@"%p",[self->outline]);
    //[self initializeEventStream];
    return YES;
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

- (void) initializeEventStream
{
    if([pathsToWatch count] == 0 )
        return;
    NSArray *paths = [NSArray arrayWithArray:pathsToWatch];
    void *appPointer = (__bridge void *)self;
    FSEventStreamContext context = {0, appPointer, NULL, NULL, NULL};
    NSTimeInterval latency = 3.0;
    stream = FSEventStreamCreate(NULL,
                                 &fsevents_callback,
                                 &context,
                                 (__bridge CFArrayRef) paths,
                                 [lastEventId unsignedLongLongValue],
                                 (CFAbsoluteTime) latency,
                                 kFSEventStreamCreateFlagUseCFTypes
                                 );
    
    FSEventStreamScheduleWithRunLoop(stream,
                                     CFRunLoopGetCurrent(),
                                     kCFRunLoopDefaultMode);
    FSEventStreamStart(stream);
}

void fsevents_callback(ConstFSEventStreamRef streamRef,
                       void *userData,
                       size_t numEvents,
                       void *eventPaths,
                       const FSEventStreamEventFlags eventFlags[],
                       const FSEventStreamEventId eventIds[])
{
    size_t i;
    for(i=0; i < numEvents; i++){
        //NSLog(@"%@",[(__bridge NSArray*)eventPaths objectAtIndex:i]);
    }
    
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
    NSURL *url = [NSURL fileURLWithPath:path];
    [self loadPath:url];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                       change:(NSDictionary *)change context:(void*)context {
    DocumentModel *dc = (DocumentModel*)object;
    //NSLog(@"Pfad geändert: %@ zu %@", [change valueForKey:NSKeyValueChangeOldKey], [change valueForKey:NSKeyValueChangeNewKey]);
    NSLog(@"Pfad geändert: %@ zu %@", [change valueForKey:NSKeyValueChangeOldKey], dc.texPath);
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
#ifdef DEBUG
    NSLog(@"FileViewController dealloc");
#endif
}

@end
