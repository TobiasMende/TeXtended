//
//  EnvironmentCompletion.m
//  TeXtended
//
//  Created by Tobias Mende on 18.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "EnvironmentCompletion.h"
#import "Constants.h"

@implementation EnvironmentCompletion

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super initWithDictionary:dict];
    if (self) {
        NSString *firstLine = [dict objectForKey:TMTCompletionsFirstLineExtensionKey];
        if (firstLine) {
            _firstLineExtension = firstLine;
        } else {
            _firstLineExtension = @"";
        }
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        _firstLineExtension = @"";
    }
    return self;
}

- (NSMutableDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dict = [super dictionaryRepresentation];
    [dict setObject:self.firstLineExtension forKey:TMTCompletionsFirstLineExtensionKey];
    return dict;
}


-(NSString *)key {
    return [NSString stringWithFormat:@"%@ | %@%@", self.insertion, self.firstLineExtension, self.extension];
}

- (BOOL)hasFirstLineExtension {
    return self.firstLineExtension && self.firstLineExtension.length > 0;
}

- (NSAttributedString *)substitutedFirstLineExtension {
    return [self substitutePlaceholdersInString:self.firstLineExtension];
}
@end
