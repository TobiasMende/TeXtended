//
//  TexdocEntry.m
//  TeXtended
//
//  Created by Tobias Mende on 23.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "TexdocEntry.h"

@implementation TexdocEntry
@synthesize description;

    - (id)initWithArray:(NSArray *)texdoc
    {
        self = [super init];
        if (self) {
            if (texdoc.count >= 4) {
                NSString *path = texdoc[2];
                if ([path isAbsolutePath]) {
                    self.path = path;
                } else {
                    self.path = [[@"~/" stringByAppendingString:path] stringByExpandingTildeInPath];
                }
                self.description = texdoc[4];
                if (self.description.length == 0) {
                    self.description = [[_path lastPathComponent] stringByDeletingPathExtension];
                }
                _score = @([texdoc[1] doubleValue]);
            }
        }

        return self;
    }

    - (NSString *)fileName
    {
        return [self.path lastPathComponent];
    }

    - (NSImage *)fileIcon
    {
        if (self.path) {
            return [[NSWorkspace sharedWorkspace] iconForFile:self.path];
        }
        return nil;
    }

    + (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
    {
        NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
        if ([key isEqualToString:@"fileName"] || [key isEqualToString:@"fileIcon"]) {
            keyPaths = [keyPaths setByAddingObject:@"path"];
        }
        return keyPaths;
    }
@end
