//
//  OutlineViewStaticAppDeligate.m
//  Sandbox
//
//  Created by Tobias Hecht on 16.04.13.
//  Copyright (c) 2013 Tobias Hecht. All rights reserved.
//

#import "FileViewController.h"

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
    id row = [outline itemAtRow:[outline clickedRow]];
    NSString *path = [row valueForKey:@"URL"];
    [self openFileInDefApp:[[NSURL alloc] initWithString:path]];
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
    
    //NSLog(@"%@",[[item class] description]);
    //NSString* oldFile = [item valueForKey:@"URL"];
    //NSString* newFile = (NSString*)object;
    //NSLog(@"%@ to %@", oldFile, newFile);
    //[self renameFile:oldFile toNewFile:newFile];
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
    [[self->outline tableColumnWithIdentifier:@"nodeName"] setDataCell:cell];
    NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Projects"];
    nodes = [[FileViewModel alloc] init];
    [nodes setPath:[[NSURL fileURLWithPath:path] path]];
    [self recursiveFileFinder:[NSURL fileURLWithPath:path]];
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
        if (! [fileUrl getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error]) {
            // handle error
        }
        else if (! [isDirectory boolValue]) {
            [self->nodes addPath:[fileUrl path]];
        }
        else
        {
            [self->nodes addPath:[fileUrl path]];
            [self recursiveFileFinder:fileUrl];
        }
    }
}

- (BOOL)loadPath: (NSURL*)url
{
    //nodes = [[NSArray alloc] initWithArray:[self recursiveFileFinder:url]];
    //[outline reloadData];
    return YES;
}

- (BOOL)openFileInDefApp: (NSURL*)url
{
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    [workspace openFile:url.path];
    return YES;
}

- (void)renameFile:(NSString*)oldPath
         toNewFile:(NSString*)newFile {
    NSString *newPath = [[oldPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:newFile];
    [[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:newPath error:nil];
}

@end
