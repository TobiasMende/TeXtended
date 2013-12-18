//
//  BibTexParser.m
//  DBLP Tool
//
//  Created by Tobias Mende on 18.12.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "TMTBibTexParser.h"
#import "TMTBibTexEntry.h"

static NSCharacterSet *IGNORED_CHARACTERS_IN_ENTRY_ATTRIBUTES;
static NSCharacterSet *LINE_END_CHARACTERS;

@interface TMTBibTexParser ()
- (void) skipComments;
- (BOOL)parseNextEntry:(NSMutableArray*)results;
- (NSString*)parseType;
- (void)parseCiteKey:(TMTBibTexEntry *)entry;
- (void)parseAttributes:(TMTBibTexEntry *)entry;
- (NSString *)parseAttributeValue;
- (NSString *)parseNestedValue;
- (NSString *)parseConcatenatedValue;
- (void)parseString;
- (void)traceError;
@end

@implementation TMTBibTexParser
+(void)initialize {
    if ([self class] == [TMTBibTexParser class]) {
        NSMutableCharacterSet *set = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
        [set addCharactersInString:@"#{,}\""];
        IGNORED_CHARACTERS_IN_ENTRY_ATTRIBUTES = set;
        LINE_END_CHARACTERS = [NSCharacterSet characterSetWithCharactersInString:@",}"];
    }
}


- (NSMutableArray *)parseBibTexIn:(NSString *)content {
    NSMutableArray *entries = [NSMutableArray new];
    strings = [NSMutableDictionary new];
    scanner = [[NSScanner alloc] initWithString:content];
    while(![scanner isAtEnd]) {
        if (![self parseNextEntry:entries]) {
            break;
        }
    }
    
    return entries;
}

- (BOOL)parseNextEntry:(NSMutableArray *)results {
    scanner.charactersToBeSkipped = nil;
    [self skipComments];
    if ([scanner scanString:@"@" intoString:NULL] || ([scanner scanUpToString:@"@" intoString:NULL] && [scanner scanString:@"@" intoString:NULL])) {
        NSString *type = [self parseType];
        if ([type.lowercaseString isEqualToString:@"string"]) {
            [self parseString];
        } else if([type.lowercaseString isEqualToString:@"comment"]) {
            return YES;
        } else if([type.lowercaseString isEqualToString:@"preamble"]) {
            return YES;
        } else {
            TMTBibTexEntry *entry = [TMTBibTexEntry new];
            entry.type = type;
            [self parseCiteKey:entry];
            [self parseAttributes:entry];
            [results addObject:entry];
        }
        return YES;
    } else {
        return NO;
    }
}

- (NSString *)parseType {
        NSString *type;
        [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"{"] intoString:&type];
    return type;
}

- (void)parseString {
    NSString *key;
    
    if ([scanner scanUpToString:@"=" intoString:&key] && [scanner scanString:@"=" intoString:NULL]) {
        NSString *value = [self parseAttributeValue];
        if (value) {
            [strings setObject:value forKey:key];
        }
        [scanner scanUpToString:@"}" intoString:NULL];
        [scanner scanString:@"}" intoString:NULL];
    }
}

- (void)parseCiteKey:(TMTBibTexEntry *)entry {
    if([scanner scanString:@"{" intoString:NULL]) {
        NSString *key;
        [scanner scanUpToCharactersFromSet:LINE_END_CHARACTERS intoString:&key];
        entry.key = key;
    }
    if (![scanner scanCharactersFromSet:LINE_END_CHARACTERS intoString:NULL]) {
        [self traceError];
    }
    
}

- (void)parseAttributes:(TMTBibTexEntry *)entry {
    while (![scanner scanString:@"}" intoString:NULL]) {
        NSString *key;
        if ([scanner scanUpToString:@"=" intoString:&key] && [scanner scanString:@"=" intoString:NULL]) {
            key = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *content = [self parseAttributeValue];
            if (content) {
                [entry setValue:content forKey:key.lowercaseString];
            }
            [scanner scanString:@"," intoString:NULL];
        } else {
            break;
        }
    }
}

- (NSString *)parseAttributeValue {
    NSString *content;
    NSMutableCharacterSet *startSet = [NSMutableCharacterSet alphanumericCharacterSet];
    [startSet addCharactersInString:@"{\","];
    scanner.charactersToBeSkipped = nil;
    if (![scanner scanUpToCharactersFromSet:startSet intoString:NULL]) {
        return nil;
    }
    if ([scanner scanString:@"," intoString:NULL]) {
        return nil;
    } else if ([scanner scanString:@"{" intoString:NULL]) {
        content = [self parseNestedValue];
    } else {
        [self parseConcatenatedValue];
    }
    return content;
}

- (NSString *)parseNestedValue {
    NSString *content = @"";
    NSInteger depth = 1;
    while (depth > 0) {
        NSString *tmp;
        if ([scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"{}"] intoString:&tmp]) {
            content = [content stringByAppendingString:tmp];
            if ([scanner scanString:@"{" intoString:NULL]) {
                depth++;
            } else if([scanner scanString:@"}" intoString:NULL]){
                depth--;
            } else {
                [self traceError];
                return nil;
            }
        }
    }
    if (content && content.length > 0) {
        return content;
    }
    return nil;
}

- (NSString *)parseConcatenatedValue {
    NSString *content;
    if ([scanner scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&content]) {
        // Value is number
        [scanner scanUpToCharactersFromSet:LINE_END_CHARACTERS intoString:NULL];
        [scanner scanCharactersFromSet:LINE_END_CHARACTERS intoString:NULL];
        return content;
    }
    content = @"";
    while (true) {
        NSString *tmp;
        if ([scanner scanString:@"\"" intoString:NULL] && [scanner scanUpToString:@"\"" intoString:&tmp] && [scanner scanString:@"\"" intoString:NULL]) {
            // Parsing '"Some text"' -> 'Some Text'
            content = [content stringByAppendingString:tmp];
        } else if ([scanner scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet] intoString:&tmp]) {
            NSString *value = [strings valueForKey:tmp];
            if (value) {
                content = [content stringByAppendingString:value];
            }
        } else if([scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\",}"] intoString:NULL]) {
            if ([scanner scanCharactersFromSet:LINE_END_CHARACTERS intoString:NULL]) {
                return (content && content.length > 0) ? content : nil;
            }
        }
    }
    
    return content;
}

- (void)skipComments {
    while (![scanner isAtEnd]) {
        if ([scanner scanString:@"%" intoString:NULL]) {
            [scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:NULL];
        } else {
            [scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:NULL];
        }
        if (![scanner scanCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:NULL])
            break;
    }
}

- (void)traceError {
    NSLog(@"BibTex Parser TRACE:");
    [self traceScannerState];
}

- (void)traceScannerState {
    NSLog(@"%@", [scanner.string substringWithRange:NSMakeRange(scanner.scanLocation, scanner.string.length - scanner.scanLocation > 20 ? 19 : scanner.string.length-scanner.scanLocation)]);
}

@end
