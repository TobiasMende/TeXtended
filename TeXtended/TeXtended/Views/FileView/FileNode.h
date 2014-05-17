//
//  FileNode.h
//  TeXtended
//
//  Created by Tobias Mende on 03.05.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>
@interface FileNode : NSObject<NSPasteboardWriting, NSPasteboardReading,QLPreviewItem>

@property (nonatomic) NSString *path;


- (NSString *)name;
- (void) setName:(NSString *)name;
- (BOOL)isLeaf;
- (NSImage *)icon;
- (NSURL *)fileURL;
- (NSMutableArray *)children;

+ (FileNode *)fileNodeWithPath:(NSString *)path;

- (IBAction)toggleRenameMode:(id)sender;

- (FileNode *)fileNodeForPath:(NSString *)path;
- (NSIndexPath *)indexPathForPath:(NSString *)path andPrefix:(NSIndexPath *)prefix;
@end
