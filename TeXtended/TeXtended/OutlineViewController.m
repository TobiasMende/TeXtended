//
//  OutlineViewStaticAppDeligate.m
//  Sandbox
//
//  Created by Tobias Hecht on 16.04.13.
//  Copyright (c) 2013 Tobias Hecht. All rights reserved.
//

#import "OutlineViewController.h"

@implementation OutlineViewStaticAppDeligate

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
    
    NSString *path = @"/Users/Tobias/Documents/Projects";
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
            [node addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSArray array], @"children", @"Datei", @"nodeDescription",filename, @"nodeName", nil]];
        }
        else
        {
            NSString *dirname = url.lastPathComponent;
            NSArray *dir = [self recursiveFileFinder:url];
            [node addObject:[NSDictionary dictionaryWithObjectsAndKeys: dir, @"children", @"Ordner", @"nodeDescription",dirname, @"nodeName",nil]];
        }
    }
    NSArray *retList = [[NSArray alloc] initWithArray:node];
    return retList;
}

- (BOOL)loadPath: (NSURL*)path
{
    nodes = [[NSArray alloc] initWithArray:[self recursiveFileFinder:path]];
    return YES; 
}

@end
