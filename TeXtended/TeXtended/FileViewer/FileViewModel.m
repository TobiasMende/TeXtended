//
//  FileViewModel.m
//  TeXtended
//
//  Created by Tobias Hecht on 15.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "FileViewModel.h"

@implementation FileViewModel

- (id)init
{
    self = [super init];
    if (self) {
        filePath = nil;
        fileName = nil;
        icon = nil;
        children = nil;
        parent = nil;
        pathComponents = nil;
        pathIndex = -1;
    }
    return self;
}

- (void)addChildren:(NSString *)path
{
    FileViewModel* newModel = [FileViewModel alloc];
    NSString* childName = [[path pathComponents] objectAtIndex:pathIndex+1];
    NSRange range;
    range.location = 0;
    range.length = pathIndex+2;
    NSArray* newModelPathComponents = [[path pathComponents] subarrayWithRange:range];
    [newModel setPath:[NSString pathWithComponents:newModelPathComponents]];
    [newModel addPath:path];
    if(children == nil)
        children = [[NSMutableArray alloc] init];
    for(NSInteger i = 0; i < [children count]; i++)
    {
        NSComparisonResult result = [childName compare:[[self getChildrenByIndex:i] getFileName]];
        if(result == NSOrderedAscending)
        {
            [children insertObject:newModel atIndex:i];
            return;
        }
    }
    [children insertObject:newModel atIndex:[children count]];
    
}

-(void)addPath:(NSString*)path
{
    NSArray* components = [path pathComponents];
    if([components count] == pathIndex+1)
        return;
    NSString* name = [components objectAtIndex:pathIndex+1];
    FileViewModel *child = [self getChildrenByName:name];
    if(child == nil)
        [self addChildren:path];
    else
        [child addPath:path];
}

-(void)setPath:(NSString*)newPath
{
    filePath = newPath;
    fileName = [filePath lastPathComponent];
    icon = [[NSWorkspace sharedWorkspace] iconForFile:filePath];
    //icon = [[NSWorkspace sharedWorkspace] iconForFile:@"/Users/"];
    pathComponents = [filePath pathComponents];
    pathIndex = [pathComponents count]-1;
    //self.presentedItemURL = [NSURL fileURLWithPath:newPath];
    _presentedItemOperationQueue = [[NSOperationQueue alloc] init];
    [_presentedItemOperationQueue setMaxConcurrentOperationCount: 1];
    
    _presentedItemURL = [NSURL fileURLWithPath:newPath];
    
    [NSFileCoordinator addFilePresenter:self];
}

- (void)presentedSubitemDidChangeAtURL:(NSURL *)url
{
    NSLog(@"%@ shoebox changed %@",fileName ,url);
    
}

-(NSString*)getFileName
{
    return fileName;
}

-(NSString*)getPath
{
    return filePath;
}

-(NSImage*)getIcon
{
    return icon;
}

-(void)setFileName:(NSString*)oldName
            toName:(NSString*)newName
{
    NSComparisonResult result = [fileName compare:oldName];
    if (result == NSOrderedSame) {
        fileName = newName;
    }
    else {
        for (NSInteger i = 0; i < [children count]; i++) {
            NSString* childrenPath = [[children objectAtIndex:i] getPath];
            if (childrenPath != nil) {
                [[children objectAtIndex:i] setFileName:oldName toName:newName];
            }
            [children setObject:newName atIndexedSubscript:i];
        }
    }
}

-(FileViewModel*)getChildrenByName:(NSString*)name
{
    if(children == nil)
        return nil;
    for (NSInteger i = 0; i < [children count]; i++) {
        NSComparisonResult result = [name compare:[[children objectAtIndex:i] getFileName]];
        if (result == NSOrderedSame) {
            return [children objectAtIndex:i];
        }
    }
    return nil;
}

-(FileViewModel*)getChildrenByIndex:(NSInteger)index
{
    if(children == nil)
        return nil;
    if ([children count] < index) {
        return nil;
    }
    return [children objectAtIndex:index];
}

-(NSInteger)numberOfChildren
{
    if(children == nil)
        return 0;
    else
        return [children count];
}

-(void)checkPath:(NSString*)path
{
    NSComparisonResult result = [path compare:filePath];
    if(!(result == NSOrderedSame))
    {
        [[self getChildrenByName:[[path pathComponents] objectAtIndex:pathIndex+1]] checkPath:path];
        return;
    }
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSURL *directoryURL = [NSURL fileURLWithPath:path]; // URL pointing to the directory you want to browse
    NSArray *keys = [NSArray arrayWithObject:NSURLIsDirectoryKey];
    
    NSArray *files = [[NSArray alloc] initWithArray:[fileManager contentsOfDirectoryAtURL:directoryURL includingPropertiesForKeys:keys options:NSDirectoryEnumerationSkipsHiddenFiles error:NULL]];
    NSUInteger count = [files count];

    for(NSInteger i = 0; i < count; i++)
    {
        NSString* file = [[[[files objectAtIndex:i] path] pathComponents] objectAtIndex:pathIndex+1];
        if([children indexOfObject:file]== NSNotFound)
            [self addPath:path];
    }
    for(NSInteger i = 0; i < [children count]; i++)
    {
        BOOL exists = FALSE;
        NSString *childrenName = [children objectAtIndex:i];
        for(NSInteger j = 0; j < count; j++)
        {
            NSString* file = [[[[files objectAtIndex:i] path] pathComponents] objectAtIndex:pathIndex+1];
            NSComparisonResult result = [childrenName compare:file];
            if (result == NSOrderedSame) {
                exists = TRUE;
            }
        }
        if (exists) {
            [children removeObject:childrenName];
        }
    }
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"FileViewModel dealloc");
#endif
}

@end