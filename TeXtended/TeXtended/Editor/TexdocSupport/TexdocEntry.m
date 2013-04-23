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

- (void)setPath:(NSString *)path {
    _path = path;
    _fileName = [path lastPathComponent];
}
@end
