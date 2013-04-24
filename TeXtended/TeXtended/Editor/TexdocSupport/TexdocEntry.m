//
//  TexdocEntry.m
//  TeXtended
//
//  Created by Tobias Mende on 23.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "TexdocEntry.h"

@implementation TexdocEntry
- (id)initWithArray:(NSArray *)texdoc {
    self = [super init];
    if (self) {
        if (texdoc.count >= 4) {
            _description = [texdoc objectAtIndex:4];
            
            _score = [NSNumber numberWithDouble:[[texdoc objectAtIndex:1] doubleValue]];
            self.path = [texdoc objectAtIndex:2];
        }
    }
    
    return self;
}

- (NSString *)fileName {
    return [self.path lastPathComponent];
}

- (NSImage*) fileIcon {
    if (self.path) {
        return [[NSWorkspace sharedWorkspace] iconForFile:self.path];
    }
    return nil;
}
@end
