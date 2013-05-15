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
        //self.view.subviews.
    }
    
    return self;
}

- (void)doubleClick:(id)object {
    //NSLog(@"DoubleClick");
    // This gets called after following steps 1-3.
    id row = [outline itemAtRow:[outline clickedRow]];
    NSString *path = [row valueForKey:@"URL"];
    //NSString *path = @"/Users/Tobias/Documents/Prototyp3.pdf";
    [self openFileInDefApp:[[NSURL alloc] initWithString:path]];
    // Do something...
}

- (id)outlineView:(NSOutlineView *)outlineView
            child:(NSInteger)index
           ofItem:(id)item
{
    if(item == nil) {
        return [nodes objectAtIndex:index];
    }
    else {
        return [[item valueForKey:@"children"] objectAtIndex:index];
    }
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
   isItemExpandable:(id)item
{
    if([[item valueForKey:@"children"] count]>0) return YES;
    
    return NO;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView
  numberOfChildrenOfItem:(id)item
{
    if(item == nil) {
        return [nodes count];
    }
    return [[item valueForKey:@"children"] count];
}

- (id)outlineView:(NSOutlineView *)outlineView
objectValueForTableColumn:(NSTableColumn *)tableColumn
           byItem:(id)item
{
    return [item valueForKey:[tableColumn identifier]];
}

- (void)outlineView:(NSOutlineView *)outlineView
     setObjectValue:(id)object
     forTableColumn:(NSTableColumn *)tableColumn
             byItem:(id)item
{
    //NSLog(@"%@",[tableColumn identifier]);
    NSDictionary *dic = [item representedObject];
    NSInteger index = [[dic allKeys] indexOfObject:[tableColumn identifier]];
    //NSString *str = [[dic allValues] objectAtIndex:index];
    //str = (NSString*)object;
    //NSLog(@"%d",index);
    //[dic setValue:(NSString*)object forKey:[tableColumn identifier]];
    //[item setValue:(NSString*)object forUndefinedKey:[tableColumn identifier]];
    NSString* oldFile = [item valueForKey:@"URL"];
    NSString* newFile = (NSString*)object;
    NSLog(@"%@ to %@", oldFile, newFile);
    //[self renameFile:oldFile toNewFile:newFile];
}

- (id)outlineView:(NSOutlineView *)ov viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item{
    if ([[item representedObject] parent] == nil) {
        return [ov makeViewWithIdentifier:@"HeaderCell" owner:self];
    }else{
        return [ov makeViewWithIdentifier:@"DataCell" owner:self];
    }
}

- (void) awakeFromNib {
    [super awakeFromNib];
    
    //[fileColumn setDataCell:[[NSBrowserCell alloc] init]];
    [self->outline setTarget:self];
    [self->outline setDoubleAction:@selector(doubleClick:)];
    //[[self->outline tableColumnWithIdentifier:@"nodeName"] setDataCell:[[NSBrowserCell alloc] init]];
}

- (NSArray*) recursiveFileFinder: (NSURL*)url
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSURL *directoryURL = url; // URL pointing to the directory you want to browse
    NSArray *keys = [NSArray arrayWithObject:NSURLIsDirectoryKey];
    
    NSArray *children = [[NSArray alloc] initWithArray:[fileManager contentsOfDirectoryAtURL:directoryURL includingPropertiesForKeys:keys options:NSDirectoryEnumerationSkipsHiddenFiles error:NULL]];
    NSUInteger count = [children count];
    NSMutableArray* node = [[NSMutableArray alloc] init];
    
    for (NSUInteger i = 0; i < count; i++) {
        NSError *error;
        NSNumber *isDirectory = nil;
        NSURL *fileUrl = [children objectAtIndex:i];
        if (! [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error]) {
            // handle error
        }
        else if (! [isDirectory boolValue]) {
            NSString *filename = fileUrl.lastPathComponent;
            [node addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray array], @"children", @"Datei", @"nodeDescription",filename, @"nodeName", fileUrl.path, @"URL", nil]];
        }
        else
        {
            NSString *dirname = fileUrl.lastPathComponent;
            NSArray *dir = [self recursiveFileFinder:fileUrl];
            [node addObject:[NSDictionary dictionaryWithObjectsAndKeys: dir, @"children", @"Ordner", @"nodeDescription",dirname, @"nodeName", fileUrl.path, @"URL", nil]];
        }
    }
    NSArray *retList = [[NSArray alloc] initWithArray:node];
    return retList;
}

- (BOOL)loadPath: (NSURL*)url
{
    nodes = [[NSArray alloc] initWithArray:[self recursiveFileFinder:url]];
    [outline reloadData];
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
    //NSLog( @"File renamed to %@", newFile );
}

@end
