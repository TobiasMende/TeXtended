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
        // Initialization code here.
    }
    
    return self;
}

- (void)doubleClick:(id)object {
    NSLog(@"DoubleClick");
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

- (void) awakeFromNib {
    [super awakeFromNib];
    
    [self->outline setTarget:self];
    [self->outline setDoubleAction:@selector(doubleClick:)];

    NSString *path = [NSString stringWithFormat:@"%@%@",NSHomeDirectory(), @"/Documents"];
    nodes = [[NSArray alloc] initWithArray:[self recursiveFileFinder:[[NSURL alloc] initWithString:path]]];
    return;
}

- (NSArray*) recursiveFileFinder: (NSURL*)path
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSURL *directoryURL = path; // URL pointing to the directory you want to browse
    NSArray *keys = [NSArray arrayWithObject:NSURLIsDirectoryKey];
    
    NSArray *children = [[NSArray alloc] initWithArray:[fileManager contentsOfDirectoryAtURL:directoryURL includingPropertiesForKeys:keys options:0 error:NULL]];
    NSUInteger count = [children count];
    NSMutableArray* node = [[NSMutableArray alloc] init];
    
    for (NSUInteger i = 0; i < count; i++) {
        NSError *error;
        NSNumber *isDirectory = nil;
        NSURL *url = [children objectAtIndex:i];
        if (! [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error]) {
            // handle error
        }
        else if (! [isDirectory boolValue]) {
            NSString *filename = url.lastPathComponent;
            [node addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray array], @"children", @"Datei", @"nodeDescription",filename, @"nodeName", url.path, @"URL", nil]];
        }
        else
        {
            NSString *dirname = url.lastPathComponent;
            NSArray *dir = [self recursiveFileFinder:url];
            [node addObject:[NSDictionary dictionaryWithObjectsAndKeys: dir, @"children", @"Ordner", @"nodeDescription",dirname, @"nodeName", url.path, @"URL", nil]];
        }
    }
    NSArray *retList = [[NSArray alloc] initWithArray:node];
    return retList;
}

- (BOOL)loadPath: (NSURL*)path
{
    nodes = [[NSArray alloc] initWithArray:[self recursiveFileFinder:path]];
    //outline.reloadData;
    return YES;
}

- (BOOL)openFileInDefApp: (NSURL*)path
{
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    [workspace openFile:path.path];
    return YES;
}

@end
