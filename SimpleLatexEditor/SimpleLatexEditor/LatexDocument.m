//
//  LatexDocument.m
//  SimpleLatexEditor
//
//  Created by Tobias Mende on 04.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "LatexDocument.h"

@implementation LatexDocument
-(id)init {
    self = [super init];
    if(self) {
        _content = [[NSString alloc] init];
        return self;
    }
    return nil;
}

- (NSString *)directoryPath {
    if(self.path != nil) {
            return [[self.path path] stringByDeletingLastPathComponent];
    }
    return nil;
}

- (NSString *)pdfPath {
    if(self.path) {
        NSString *file = [[self.path path] stringByDeletingPathExtension];
        NSString *pdfPath = [NSString stringWithFormat:@"%@.pdf", file];
        return pdfPath;
    }
    return nil;
}

    // self.content = @"bla" <-> [self setContent:@"bla"];
@end
