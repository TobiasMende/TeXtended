//
//  BibFile.m
//  TeXtended
//
//  Created by Tobias Mende on 01.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "BibFile.h"
#import "ProjectModel.h"


@implementation BibFile

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.lastRead = [aDecoder decodeObjectForKey:@"lastRead"];
        self.project = [aDecoder decodeObjectForKey:@"project"];
        self.path = [aDecoder decodeObjectForKey:@"path"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.lastRead forKey:@"lastRead"];
    [aCoder encodeConditionalObject:self.project forKey:@"project"];
    [aCoder encodeObject:self.path forKey:@"path"];
}

@end
