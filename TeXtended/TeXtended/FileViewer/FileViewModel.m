//
//  FileViewModel.m
//  TeXtended
//
//  Created by Tobias Hecht on 15.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "FileViewModel.h"
#import "DocumentModel.h"

@implementation FileViewModel

- (id)init
{
    self = [super init];
    if (self) {
        pathIndex = -1;
        self.expandable = FALSE;
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
    [newModel setFilePath:[NSString pathWithComponents:newModelPathComponents]];
    [newModel addPath:path];
    newModel.parent = self;
    if(children == nil)
    {
        children = [[NSMutableArray alloc] init];
        self.expandable = TRUE;
    }
    for(NSInteger i = 0; i < [children count]; i++)
    {
        if([[[self getChildrenByIndex:i] fileName] isEqualToString:childName])
        {
            [children insertObject:newModel atIndex:i];
            return;
        }
    }
    [children insertObject:newModel atIndex:[children count]];
}

-(void)addPath:(NSString*)path
{
    if([path isEqualToString:self.filePath])
    {
        return;
    }
    NSMutableArray* components = [[path pathComponents] mutableCopy];
    NSString* name = [components objectAtIndex:pathIndex+1];
    FileViewModel *child = [self getChildrenByName:name];
    if(child == nil)
    {
        [self addChildren:path];
    }
    else
    {
        [child addPath:path];
    }
}

-(void)addModel:(FileViewModel*)newModel
{
    if(children == nil)
    {
        children = [[NSMutableArray alloc] init];
    }
    NSString* childName = newModel.fileName;
    NSInteger index = [children count];
    for(NSInteger i = 0; i < [children count]; i++)
    {
        if([[[self getChildrenByIndex:i] fileName] isEqualToString:childName])
        {
            index = i;
        }
    }
    [children insertObject:newModel atIndex:index];
    newModel.parent = self;
    [newModel updateFilePath:[self.filePath stringByDeletingLastPathComponent]];
}

-(void)setFilePath:(NSString*)newPath
{
    [self willChangeValueForKey:@"filePath"];
    _filePath = newPath;
    [self didChangeValueForKey:@"filePath"];
    self.fileName = [self.filePath lastPathComponent];
    self.icon = [[NSWorkspace sharedWorkspace] iconForFile:self.filePath];
    self.pathComponents = [self.filePath pathComponents];
    pathIndex = [self.pathComponents count]-1;
    [[NSFileManager defaultManager] fileExistsAtPath:self.filePath isDirectory:&_isDir];
}

-(void)updateFilePath:(NSString*)newPath
{
    self.filePath = [newPath stringByAppendingPathComponent:self.fileName];
    self.pathComponents = [self.filePath pathComponents];
    pathIndex = [self.pathComponents count]-1;
    
    if(children)
    {
        for(NSInteger i = 0; i < [children count]; i++)
        {
            [[children objectAtIndex:i] updateFilePath:self.filePath];
        }
    }
}

-(void)setFileName:(NSString*)oldPath
            toName:(NSString*)newName
{
    if ([oldPath isEqualToString:self.filePath]) {
        self.fileName = newName;
        NSString* newPath = [[oldPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:newName];
        [self willChangeValueForKey:@"filePath"];
        _filePath = newPath;
        [self didChangeValueForKey:@"filePath"];
        [self willChangeValueForKey:@"pathComponents"];
        _pathComponents = [self.filePath pathComponents];
        [self didChangeValueForKey:@"pathComponents"];
        if(children)
        {
            for (NSInteger i = 0; i < [children count]; i++) {
                [[self getChildrenByIndex:i] setFileNameOfParent:newName atComponentIndex:pathIndex];
            }
        }
    }
    else {
        NSArray *components = [oldPath pathComponents];
        NSInteger index = pathIndex+1;
        for (NSInteger i = 0; i < [children count]; i++) {
            FileViewModel* actChildren = [self getChildrenByIndex:i];
            NSArray* childrenComponents = [actChildren pathComponents];
            if([[childrenComponents objectAtIndex:index] isEqualToString:[components objectAtIndex:index]])
            {
                [actChildren setFileName:oldPath toName:newName];
            }
        }
    }
}

-(void)setFileNameOfParent:(NSString*)name
          atComponentIndex:(NSInteger)index
{
    NSString *newPath = @"";
    for (NSInteger i = 0; i < [self.pathComponents count]; i++) {
        if(i == index)
        {
            [newPath stringByAppendingPathComponent:name];
        }
        else
        {
            [newPath stringByAppendingPathComponent:[self.pathComponents objectAtIndex:i]];
        }
    }
    [self willChangeValueForKey:@"filePath"];
    _filePath = newPath;
    [self didChangeValueForKey:@"filePath"];
    [self willChangeValueForKey:@"pathComponents"];
    _pathComponents = [self.filePath pathComponents];
    [self didChangeValueForKey:@"pathComponents"];
    
    for(NSInteger i = 0; i < [children count]; i++)
    {
        [[self getChildrenByIndex:i] setFileNameOfParent:name atComponentIndex:index];
    }
}

-(FileViewModel*)getChildrenByName:(NSString*)name
{
    if(children == nil)
    {
        return nil;
    }
    for (NSInteger i = 0; i < [children count]; i++) {
        if ([[[children objectAtIndex:i] fileName] isEqualToString:name]) {
            return [children objectAtIndex:i];
        }
    }
    return nil;
}

-(FileViewModel*)getChildrenByIndex:(NSInteger)index
{
    if(children == nil)
    {
        return nil;
    }
    if ([children count] < index) {
        return nil;
    }
    return [children objectAtIndex:index];
}

-(NSInteger)numberOfChildren
{
    if(children == nil)
    {
        return 0;
    }
    else
    {
        return [children count];
    }
}

-(void)checkPath:(NSString*)path
{
    if([path isEqualToString:self.filePath])
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
        {
            [self addPath:path];
        }
    }
    for(NSInteger i = 0; i < [children count]; i++)
    {
        BOOL exists = FALSE;
        NSString *childrenName = [children objectAtIndex:i];
        for(NSInteger j = 0; j < count; j++)
        {
            NSString* file = [[[[files objectAtIndex:i] path] pathComponents] objectAtIndex:pathIndex+1];
            if ([childrenName isEqualToString:file]) {
                exists = TRUE;
            }
        }
        if (exists) {
            [children removeObject:childrenName];
        }
    }
}

-(void)addDocumentModel:(DocumentModel*)newModel
                 atPath:(NSString*)path
{
    if([path isEqualToString:self.filePath])
    {
        self.docModel = newModel;
        return;
    }
    NSString* childrenName = [[path pathComponents] objectAtIndex:pathIndex+1];
    [[self getChildrenByName:childrenName] addDocumentModel:newModel atPath:path];
}

-(void)addExitsingChildren:(FileViewModel*)newChildren
{
    [newChildren.parent removeChildren:newChildren];
    if(children == nil)
    {
        children = [[NSMutableArray alloc] init];
    }
    NSString* childName = newChildren.fileName;
    NSInteger index = [children count];
    for(NSInteger i = 0; i < [children count]; i++)
    {
        if([[[self getChildrenByIndex:i] fileName] isEqualToString:childName])
        {
            index = i;
        }
    }
    [children insertObject:newChildren atIndex:index];
    newChildren.parent = self;
    [newChildren updateFilePath:self.filePath];
}

-(void)removeChildren:(FileViewModel*) childrenModel
{
    [children removeObject:childrenModel];
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"FileViewModel dealloc");
#endif
}
@end