//
//  FileNode.m
//  TeXtended
//
//  Created by Tobias Mende on 03.05.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "FileNode.h"
#import <TMTHelperCollection/TMTLog.h>

@implementation FileNode


+ (FileNode *)fileNodeWithPath:(NSString *)path {
    FileNode *node = [FileNode new];
    node.path = path;
    
    return node;
}


+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    NSSet *keys = [super keyPathsForValuesAffectingValueForKey:key];
    if ([key isEqualToString:@"name"] || [key isEqualToString:@"isLeaf"] || [key isEqualToString:@"icon"] || [key isEqualToString:@"children"]) {
        keys = [keys setByAddingObject:@"path"];
    }
    return keys;
}

- (NSString *)name {
    return self.path.lastPathComponent;
}

- (BOOL)isLeaf {
    BOOL isDir;
    [[NSFileManager defaultManager] fileExistsAtPath:self.path isDirectory:&isDir];
    return  !isDir;

}

- (NSImage *)icon {
    return [[NSWorkspace sharedWorkspace] iconForFile:self.path];
}

- (NSMutableArray *)children {
    
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:[NSURL fileURLWithPath:self.path] includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants|NSDirectoryEnumerationSkipsSubdirectoryDescendants|NSDirectoryEnumerationSkipsHiddenFiles errorHandler:nil];

    NSMutableArray *contents = [NSMutableArray new];

    
    for(NSURL *url in enumerator) {
        [contents addObject:[FileNode fileNodeWithPath:url.path]];
    }
    
    return contents;
}

- (NSString *)description {
    return self.path;
}

- (NSUInteger)hash {
    NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * result + [self.path hash];
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[FileNode class]] && [[(FileNode*)object path] isEqualToString:self.path];
}

@end
