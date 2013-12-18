//
//  CiteCompletion.m
//  TeXtended
//
//  Created by Tobias Mende on 18.12.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "CiteCompletion.h"
#import "CompletionProtocol.h"
#import "DBLPPublication.h"
@implementation CiteCompletion
- (NSString *)key {
    return self.entry.key;
}

- (NSString *)autoCompletionWord {
    return self.key;
}
@end
