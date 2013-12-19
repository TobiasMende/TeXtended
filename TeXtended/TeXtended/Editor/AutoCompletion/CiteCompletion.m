//
//  CiteCompletion.m
//  TeXtended
//
//  Created by Tobias Mende on 18.12.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "CiteCompletion.h"
#import "CompletionProtocol.h"
#import <BibTexToolsFramework/TMTBibTexEntry.h>
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
    result |= [self.entry.title.lowercaseString hasPrefix:prefix.lowercaseString];
    result |= [self.key.lowercaseString hasPrefix:prefix.lowercaseString];
    if (self.entry.author) {
        NSRange nameRange = [self.entry.author.lowercaseString rangeOfString:prefix.lowercaseString];
        result |= nameRange.location != NSNotFound;
    }
    if([self.entry valueForKey:@"keywords"]) {
         NSRange range = [[self.entry valueForKey:@"keywords"] rangeOfString:prefix.lowercaseString];
        result |= range.location != NSNotFound;
    }
    return result;
}
@end
