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

- (void)doubleClick:(id)object {
    FileViewModel* model = (FileViewModel*)[outline itemAtRow:[outline clickedRow]];
    NSString *path = [model getPath];
    NSLog(@"%@",path);
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
    return [model getFileName];
}

- (void)outlineView:(NSOutlineView *)outlineView
     setObjectValue:(id)object
     forTableColumn:(NSTableColumn *)tableColumn
             byItem:(id)item
{
    FileViewModel *model = (FileViewModel*)item;
    NSString* oldFile = [model getPath];
    NSString* newFile = (NSString*)object;
    NSLog(@"%@",newFile);
    [self renameFile:oldFile toNewFile:newFile];
}

- (void)    outlineView:(NSOutlineView *)outlineView
        willDisplayCell:(id)cell
         forTableColumn:(NSTableColumn *)tableColumn
                   item:(id)item
{
    FileViewModel *model = (FileViewModel*)item;
    CGFloat max = 17;
    CGFloat scale = 0;
    NSImage *img = [model getIcon];
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
    [self->outline setDoubleAction:@selector(doubleClick:)];
    NSBrowserCell *cell = [[NSBrowserCell alloc] init];
    [cell setLeaf:YES];
    [cell setEditable:YES];
    
    [[self->outline tableColumnWithIdentifier:@"nodeName"] setDataCell:cell];
    pathsToWatch = [[NSMutableArray alloc] init];
    nodes = [[FileViewModel alloc] init];
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
    [self->nodes setPath:[url path]];
    [self recursiveFileFinder:url];
    [self->outline reloadData];
    //NSLog(@"%p",[self->outline]);
    [self initializeEventStream];
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
    NSString *totalPath;
    if (document.project) {
        totalPath = document.project.path;
    } else {
        totalPath = document.texPath;
    }
    totalPath = @"/Users/Tobias/Documents/Projects";
    if(!totalPath ||[totalPath length] == 0)
        return;
    NSString *path = [totalPath stringByDeletingLastPathComponent];
    //NSString* path = totalPath;
    NSURL *url = [NSURL fileURLWithPath:path];
    [self loadPath:url];
}

@end
