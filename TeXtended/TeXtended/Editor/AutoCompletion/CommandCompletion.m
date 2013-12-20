//
//  CommandCompletion.m
//  TeXtended
//
//  Created by Tobias Mende on 18.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "CommandCompletion.h"
#import "Constants.h"
#import "CompletionManager.h"

static const NSArray *COMPLETION_TYPES;


@implementation CommandCompletion

+ (void)initialize {
    COMPLETION_TYPES = @[CommandTypeNormal, CommandTypeCite, CommandTypeLabel, CommandTypeRef];
}


- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super initWithDictionary:dict];
    if (self) {
        NSString *type = [dict valueForKey:TMTCompletionTypeKey];
        self.completionType = type ? type : CommandTypeNormal;
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


- (void)setCompletionType:(NSString *)completionType {
    if (![_completionType isEqualToString:completionType]) {
        CompletionManager *m = [CompletionManager sharedInstance];
        [m removeFromTypeIndex:self];
        _completionType = completionType;
        [m addToTypeIndex:self];
    }
}

- (NSMutableDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dict = [super dictionaryRepresentation];
    if(self.completionType && ![self.completionType isEqualToString:CommandTypeNormal]) {
        dict[TMTCompletionTypeKey] = self.completionType;
    }
    return dict;
}

- (NSString *)autoCompletionWord {
    return [self.insertion substringFromIndex:1];
}

- (void)dealloc {
    [[CompletionManager sharedInstance] removeFromTypeIndex:self];
}

@end