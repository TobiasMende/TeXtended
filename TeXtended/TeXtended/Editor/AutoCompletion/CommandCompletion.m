//
//  CommandCompletion.m
//  TeXtended
//
//  Created by Tobias Mende on 18.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "CommandCompletion.h"
#import "Constants.h"


static const NSArray *COMPLETION_TYPES;
@implementation CommandCompletion

+ (void)initialize {
    COMPLETION_TYPES = [[NSArray alloc] initWithObjects:@"normal", @"cite", @"label", @"ref", nil];
}

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super initWithDictionary:dict];
    if (self) {
        _completionType = [dict valueForKey:TMTCompletionTypeKey];
    }
return self;
}

- (void)setInsertion:(NSString *)insertion {
    if (![[insertion substringToIndex:1] isEqualToString:@"\\"]) {
        [super setInsertion:[@"\\" stringByAppendingString:insertion]];
    }else {
        [super setInsertion:insertion];
    }
}

- (NSString *)completionType {
    if(_completionType) {
        return _completionType;
    }
    return [[COMPLETION_TYPES objectAtIndex:0] copy];
}

- (NSMutableDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dict = [super dictionaryRepresentation];
    if(_completionType) {
        [dict setObject:self.completionType forKey:TMTCompletionTypeKey];
    }
    return dict;
}

@end