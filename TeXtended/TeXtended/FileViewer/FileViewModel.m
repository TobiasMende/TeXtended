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
    [newModel addPath:path];
    if(children == nil)
        children = [NSMutableArray alloc];
    for(NSInteger i = 0; i < [children count]; i++)
    {
        NSComparisonResult result = [childName compare:[[self getChildren:i] getFileName]];
        if(result == NSOrderedDescending)
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
    fileName = [components objectAtIndex:pathIndex+1];
    FileViewModel *child = [self getChildren:[components indexOfObject:fileName]];
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
    pathComponents = [filePath pathComponents];
    pathIndex = [pathComponents count]-1;
}

-(NSString*)getFileName
{
    return fileName;
}

-(NSString*)getPath
{
    if (children == nil)
        return nil;
    else
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

-(FileViewModel*)getChildren:(NSInteger)index
{
    if(children == nil)
        return nil;
    if([children count] >= index)
        return nil;
    return [children objectAtIndex:index];
}

-(NSInteger)numberOfChildren
{
    if(children == nil)
        return 0;
    else
        return [children count];
}

@end
/*
0
 1
1
 2
2
 2
3
 3
4
 4
5
 5
6
 6
7
 
*/