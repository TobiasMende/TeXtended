//
//  FileNode.m
//  TeXtended
//
//  Created by Tobias Mende on 03.05.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <TMTHelperCollection/TMTLog.h>

#import "FileNode.h"

@implementation FileNode

#pragma mark - Getter

    - (NSMutableArray *)children
    {
        NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:[NSURL fileURLWithPath:self.path] includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsHiddenFiles errorHandler:nil];

        NSMutableArray *contents = [NSMutableArray new];


        for (NSURL *url in enumerator) {
            [contents addObject:[FileNode fileNodeWithPath:url.path]];
        }

        return contents;
    }

    - (NSString *)description
    {
        return self.path;
    }

    - (NSURL *)fileURL
    {
        return [NSURL fileURLWithPath:self.path];
    }

    - (NSImage *)icon
    {
        return [[NSWorkspace sharedWorkspace] iconForFile:self.path];
    }

    - (BOOL)isLeaf
    {
        BOOL isDir;

        [[NSFileManager defaultManager] fileExistsAtPath:self.path isDirectory:&isDir];
        return !isDir;
    }

    - (NSString *)name
    {
        return self.path.lastPathComponent;
    }



#pragma mark - Setter

    - (void)setName:(NSString *)name
    {
        if (!name || name.length == 0 || [name isEqualTo:self.name]) {
            return;
        }
        self.path = [[self.path stringByDeletingLastPathComponent] stringByAppendingPathComponent:name];
    }

    - (void)setPath:(NSString *)path
    {
        if ([path isEqualTo:_path]) {
            return;
        }
        NSString *oldPath = _path;
        _path = path;
        if (oldPath) {
            NSFileManager *fm = [NSFileManager defaultManager];
            NSError *error;
            [fm moveItemAtPath:oldPath toPath:path error:&error];
            if (error) {
                DDLogError(@"Can't set path! %@", error.userInfo);
            }
        }
    }


#pragma mark - Comparision

    - (NSUInteger)hash
    {
        NSUInteger prime = 31;
        NSUInteger result = 1;

        result = prime * result + [self.path hash];
    }

    - (BOOL)isEqual:(id)object
    {
        return [object isKindOfClass:[FileNode class]] && [[(FileNode *) object path] isEqualToString:self.path];
    }

    - (FileNode *)fileNodeForPath:(NSString *)path
    {
        if (![path hasPrefix:self.path]) {
            return nil;
        }
        if ([path isEqualTo:self.path]) {
            return self;
        }
        for (FileNode *node in self.children) {
            if ([path hasPrefix:[self.path stringByAppendingString:@"/"]]) {
                return [node fileNodeForPath:path];
            }
        }
        return nil;
    }


#pragma mark - File Path Helpers

    + (FileNode *)fileNodeWithPath:(NSString *)path
    {
        FileNode *node = [FileNode new];

        node.path = path;

        return node;
    }

    - (NSIndexPath *)indexPathForPath:(NSString *)path andPrefix:(NSIndexPath *)prefix
    {
        if (![path hasPrefix:self.path]) {
            return nil;
        }
        if ([path isEqualTo:self.path]) {
            return prefix;
        }
        NSUInteger count = 0;
        for (FileNode *node in self.children) {
            if ([path hasPrefix:[self.path stringByAppendingString:@"/"]]) {
                NSIndexPath *result = [node indexPathForPath:path andPrefix:[prefix indexPathByAddingIndex:count]];
                if (result) {
                    return result;
                }
            }
            count++;
        }
        return nil;
    }

#pragma mark - Pasteboard Support (Drag & Drop)


#pragma mark  NSPasteboardWriting Support

    - (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard
    {
        return [self.fileURL writableTypesForPasteboard:pasteboard];
    }

    - (NSPasteboardWritingOptions)writingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pasteboard
    {
        return [self.fileURL writingOptionsForType:type pasteboard:pasteboard];
    }

    - (id)pasteboardPropertyListForType:(NSString *)type
    {
        return [self.fileURL pasteboardPropertyListForType:type];
    }


#pragma mark NSPasteboardReading Support

    + (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard
    {
        // We allow creation from URLs so Finder items can be dragged to us
        return [NSURL readableTypesForPasteboard:pasteboard];
    }

    + (NSPasteboardReadingOptions)readingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pasteboard
    {
        [NSURL readingOptionsForType:type pasteboard:pasteboard];
    }

    - (id)initWithPasteboardPropertyList:(id)propertyList ofType:(NSString *)type
    {
        // See if an NSURL can be created from this type

        NSURL *url = [[NSURL alloc] initWithPasteboardPropertyList:propertyList ofType:type];

        if (url) {
            self = [super init];
            self.path = url.path;
            return self;
        }
        return nil;
    }


#pragma mark - Quick Look Support (QLPreviewItem Methods)

    - (NSString *)previewItemTitle
    {
        return self.name;
    }

    - (NSURL *)previewItemURL
    {
        return self.fileURL;
    }


#pragma mark - Key Value Coding

    + (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
    {
        NSSet *keys = [super keyPathsForValuesAffectingValueForKey:key];

        if ([key isEqualToString:@"name"] || [key isEqualToString:@"isLeaf"] || [key isEqualToString:@"icon"] || [key isEqualToString:@"children"] || [key isEqualToString:@"fileURL"]) {
            keys = [keys setByAddingObject:@"path"];
        }
        return keys;
    }


@end
