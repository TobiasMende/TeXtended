//
//  CiteCompletion.m
//  TeXtended
//
//  Created by Tobias Mende on 18.12.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "CiteCompletion.h"
#import "CompletionProtocol.h"
#import "TMTBibTexEntry.h"
@implementation CiteCompletion
- (id)initWithBibEntry:(TMTBibTexEntry *)entry {
    self = [super init];
    if (self) {
        self.entry = entry;
    }
    return self;
}

- (NSString *)key {
    return self.entry.key;
}

- (NSString *)autoCompletionWord {
    return self.entry.title;
}

- (NSComparisonResult)compare:(CiteCompletion *)other {
    return [self.entry compare:other.entry];
}

- (BOOL)completionMatchesPrefix:(NSString *)prefix {
    BOOL result = NO;
    result |= [self.entry.title hasPrefix:prefix];
    result |= [self.key hasPrefix:prefix];
    if (self.entry.author) {
        NSRange nameRange = [self.entry.author rangeOfString:prefix];
        result |= nameRange.location != NSNotFound;
    }
    return result;
}
@end
