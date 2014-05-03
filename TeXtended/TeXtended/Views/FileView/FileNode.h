//
//  FileNode.h
//  TeXtended
//
//  Created by Tobias Mende on 03.05.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileNode : NSObject

@property NSString *path;


- (NSString *)name;
- (BOOL)isLeaf;
- (NSImage *)icon;
- (NSMutableArray *)children;

+ (FileNode *)fileNodeWithPath:(NSString *)path;

@end
