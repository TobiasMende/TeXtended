//
//  OutlineElement.m
//  TeXtended
//
//  Created by Tobias Mende on 02.08.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "OutlineElement.h"
#import "DocumentModel.h"
#import "TMTLog.h"

static const NSDictionary *ELEMENT_EXTRACTOR_REGEX_LOOKUP;
static const NSDictionary *TYPE_STRING_LOOKUP;

@implementation OutlineElement

+ (void)initialize {
    if (self == [OutlineElement class]) {
        ELEMENT_EXTRACTOR_REGEX_LOOKUP = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"OutlineElementTypeLookupTable" ofType:@"plist"]];
        TYPE_STRING_LOOKUP = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"OutlineElementTypeStringLookupTable" ofType:@"plist"]];
    }
}

+ (NSSet *)extractIn:(NSString *)content for:(DocumentModel *)model {
    // TODO: Handle extraction process
}

+ (NSRegularExpression *)regexForElementType:(OutlineElementType)type {
    NSString *key = [NSString stringWithFormat:@"%i", type];
    NSString *regexStr = [ELEMENT_EXTRACTOR_REGEX_LOOKUP objectForKey:key];
    NSError *error;
    if (!regexStr) {
        return nil;
    }
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr options:0 error:&error];
    if (error) {
        DDLogError(@"OutlineElement: Can't create regex for type %i and pattern %@", type,regexStr);
        return nil;
    }
    return regex;
}

+ (NSString *)stringForType:(OutlineElementType)type {
    return [TYPE_STRING_LOOKUP objectForKey:[NSString stringWithFormat:@"%i", type]];
}

@end
