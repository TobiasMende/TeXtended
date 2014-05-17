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

#pragma mark - Properties

@property (nonatomic) NSString *path;


#pragma mark - Getter

- (NSMutableArray *)children;

- (NSURL *)fileURL;

- (NSImage *)icon;

- (BOOL)isLeaf;

- (NSString *)name;


#pragma mark - Setter

- (void) setName:(NSString *)name;


#pragma mark - File Path Helpers

+ (FileNode *)fileNodeWithPath:(NSString *)path;

- (IBAction)toggleRenameMode:(id)sender;

- (FileNode *)fileNodeForPath:(NSString *)path;

- (NSIndexPath *)indexPathForPath:(NSString *)path andPrefix:(NSIndexPath *)prefix;

@end
