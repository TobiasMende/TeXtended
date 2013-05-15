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
        childs = nil;
        parent = nil;
    }
    return self;
}

- (void)addChild:(NSString *)path
{
    FileViewModel* newModel = [FileViewModel alloc];
    [newModel setPath:path];
    if(childs == nil)
        childs = [NSMutableArray alloc];
    for(NSInteger i = 0; i < [childs count]; i++)
    {
        NSComparisonResult result = [fileName compare:[[childs objectAtIndex:i] getFileName]];
        if(result == NSOrderedDescending)
        {
            [childs insertObject:newModel atIndex:i];
            return;
        }
    }
    [childs insertObject:newModel atIndex:[childs count]];
    
}

-(void)setPath:(NSString*)newPath
{
    filePath = newPath;
    fileName = [filePath lastPathComponent];
    icon = [[NSWorkspace sharedWorkspace] iconForFile:filePath];
}

-(NSString*)getFileName
{
    return fileName;
}

-(FileViewModel*)getChild:(NSInteger)index
{
    if(childs == nil)
        return nil;
    if([childs count] >= index)
        return nil;
    return [childs objectAtIndex:index];
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