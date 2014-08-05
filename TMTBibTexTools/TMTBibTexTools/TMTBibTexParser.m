//
//  BibTexParser.m
//  DBLP Tool
//
//  Created by Tobias Mende on 18.12.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "TMTBibTexParser.h"
#import "TMTBibTexEntry.h"
#import <TMTHelperCollection/TMTLog.h>

static NSCharacterSet *IGNORED_CHARACTERS_IN_ENTRY_ATTRIBUTES;
static NSCharacterSet *LINE_END_CHARACTERS;

@interface TMTBibTexParser ()
/**
 Methods moves the scanners cursor behing comments if any
 */
- (void) skipComments;

/**
 Parses the entire next bib entry if available.
 @param results an array to be filled with the results.
 @return `YES` if the scanner was able to parse an entry or `NO` if something went wrong (e.g. wrong position)
 */
- (BOOL)parseNextEntry:(NSMutableArray*)results;

/** Parses the entries type
 @return the type
 */
- (NSString*)parseType;

/** Parses the cite key and writes the result into the given entry.
 @param entry the entry to put the key in
 */
- (void)parseCiteKey:(TMTBibTexEntry *)entry;

/** Parses all attributes of the entry in front of the scanners cursor into the given TMTBibTexEntry.
 An attribute is defined as `key = value`.
 @param entry the object to fill with the parsed attributes.

 */
- (void)parseAttributes:(TMTBibTexEntry *)entry;

/**
  Parses the value of an attribute.
 @return the attributes value or `nil` if the algorithm fails (e.g. wrong position, invalid file).
 */
- (NSString *)parseAttributeValue;

/**
 Parses the value if it is nested (it starts with {)
 @return the value as clean string if it was found, `nil` otherwise.
 */
- (NSString *)parseNestedValue;

/**
 Parses the value if it is concatenated (e.g. "something" # "otherthing")
 @return the total concatenated value (e.g. "stringA " # "stringB" --> "stringA stringB")
 */
- (NSString *)parseConcatenatedValue;

/**
 Parses string entries into `strings`. Strings are used like variables in bibtex and are automatically replaced when parsing the values.
 */
- (void)parseString;

/**
 Logs an error and the current scanner state
 @see [self traceScannerState]
 */
- (void)traceError;

/**
 Logs the scanner state (the location, the string under the cursor)
 */
- (void)traceScannerState;
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

# pragma mark - Iterating through the content

- (NSMutableArray *)parseBibTexIn:(NSString *)content {
    NSMutableArray *entries = [NSMutableArray new];
    strings = [NSMutableDictionary new];
    scanner = [[NSScanner alloc] initWithString:content];
    lastScanLocation = scanner.scanLocation;
    while(![scanner isAtEnd]) {
        if (![self parseNextEntry:entries]) {
            break;
        }
        if (lastScanLocation == scanner.scanLocation) {
            [self traceError];
            break;
        }
        lastScanLocation = scanner.scanLocation;
    }
    DDLogVerbose(@"Found %ld entries", entries.count);
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

#pragma mark - Scanning other content

- (void)parseString {
    NSString *key;
    
    if ([scanner scanUpToString:@"=" intoString:&key] && [scanner scanString:@"=" intoString:NULL]) {
        NSString *value = [self parseAttributeValue];
        key = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (value) {
            strings[key] = value;
        }
        [scanner scanUpToString:@"}" intoString:NULL];
        [scanner scanString:@"}" intoString:NULL];
    }
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

#pragma mark - Extracting general cite informations
- (NSString *)parseType {
    NSString *type;
    [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"{"] intoString:&type];
    return type;
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

#pragma mark - Extracting the attributes
- (void)parseAttributes:(TMTBibTexEntry *)entry {
    // Loops through every line of kind 'key = value'
    while (![scanner scanString:@"}" intoString:NULL]) {
        NSString *key;
        scanner.charactersToBeSkipped = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        if ([scanner scanUpToString:@"=" intoString:&key] && [scanner scanString:@"=" intoString:NULL]) {
            key = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *content = [self parseAttributeValue];
            if (content) {
                [entry setValue:content forKey:key.lowercaseString];
            }
            scanner.charactersToBeSkipped = [NSCharacterSet whitespaceAndNewlineCharacterSet];
            
            // Consume the following ',' if available:
            [scanner scanString:@"," intoString:NULL];
        } else {
            break;
        }
    }
}

#pragma mark Extracting the value

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
    lastScanLocation = scanner.scanLocation;
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
        if (lastScanLocation == scanner.scanLocation) {
            [self traceError];
            break;
        } else {
            lastScanLocation = scanner.scanLocation;
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
    lastScanLocation = scanner.scanLocation;
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
        if (lastScanLocation == scanner.scanLocation) {
            [self traceError];
            break;
        } else {
            lastScanLocation = scanner.scanLocation;
        }
    }
    
    return content;
}

#pragma mark - Debugging

- (void)traceError {
    DDLogError(@"BibTex Parser TRACE:");
    [self traceScannerState];
    DDLogVerbose(@"%@", [NSThread callStackSymbols]);
}

- (void)traceScannerState {
    DDLogInfo(@"%@", [scanner.string substringWithRange:NSMakeRange(scanner.scanLocation, scanner.string.length - scanner.scanLocation > 20 ? 19 : scanner.string.length-scanner.scanLocation)]);
}

@end
