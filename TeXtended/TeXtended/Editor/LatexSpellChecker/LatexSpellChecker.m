//
//  LatexSpellChecker.m
//  TeXtended
//
//  Created by Tobias Mende on 08.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "LatexSpellChecker.h"
#import <TMTHelperCollection/TMTLog.h>
#import "NSString+LatexExtension.h"

@interface LatexSpellChecker ()
- (NSArray *)removeCommandResultsFrom:(NSArray *)results inContext:(NSString *)content;
- (NSString *)descriptionForResultType:(NSTextCheckingType)type;
@end

@implementation LatexSpellChecker

- (id)init {
    self = [super init];
    if (self) {
        weakSelf = self;
    }
    return self;
}


- (NSArray *)checkString:(NSString *)stringToCheck range:(NSRange)range types:(NSTextCheckingTypes)checkingTypes options:(NSDictionary *)options inSpellDocumentWithTag:(NSInteger)tag orthography:(NSOrthography *__autoreleasing *)orthography wordCount:(NSInteger *)wordCount {
    return nil;
}

- (NSRange)checkSpellingOfString:(NSString *)stringToCheck startingAt:(NSInteger)startingOffset {
    return NSMakeRange(NSNotFound, 0);
}

- (NSRange)checkSpellingOfString:(NSString *)stringToCheck startingAt:(NSInteger)startingOffset language:(NSString *)language wrap:(BOOL)wrapFlag inSpellDocumentWithTag:(NSInteger)tag wordCount:(NSInteger *)wordCount {
    return NSMakeRange(NSNotFound, 0);
}

- (NSInteger)requestCheckingOfString:(NSString *)stringToCheck range:(NSRange)range types:(NSTextCheckingTypes)checkingTypes options:(NSDictionary *)options inSpellDocumentWithTag:(NSInteger)tag completionHandler:(void (^)(NSInteger, NSArray *, NSOrthography *, NSInteger))callersHandler {
    
    void (^completionHandler)(NSInteger, NSArray *, NSOrthography *, NSInteger);
    
    completionHandler = ^(NSInteger sequenceNumber, NSArray *tmpResults, NSOrthography *orthography, NSInteger wordCount) {
        
        // TODO: implement spell checking here
        
        NSArray *results = [weakSelf removeCommandResultsFrom:tmpResults inContext:stringToCheck];
        
        
        callersHandler(sequenceNumber, results, orthography, wordCount);
    };
    
    return [super requestCheckingOfString:stringToCheck range:range types:checkingTypes options:options inSpellDocumentWithTag:tag completionHandler:completionHandler];
}

- (NSArray *)removeCommandResultsFrom:(NSArray *)results inContext:(NSString *)content {
    NSMutableArray *finalResults = [NSMutableArray arrayWithCapacity:results.count];
    if (!prefixesToIgnore) {
        NSString *strings = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]
                                                                pathForResource:@"SpellCheckerPrefixesToIgnore" ofType:@"list"] encoding:NSUTF8StringEncoding error:NULL];

        prefixesToIgnore = [strings componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        if (!prefixesToIgnore) {
            DDLogError(@"Can't load prefixes!");
        }

    }
    
    for(NSTextCheckingResult *result in results) {
        //DDLogWarn(@"%li, %@ : %@", result.numberOfRanges, [self descriptionForResultType:result.resultType], [content substringWithRange:result.range]);
        NSRange range = result.range;
        if (result.resultType != NSTextCheckingTypeSpelling) {
            [finalResults addObject:result];
            continue;
        }
        if(![content numberOfBackslashesBeforePositionIsEven:range.location]) {
            // It's a command:
            continue;
        }
        NSRange prefix = [content latexCommandPrefixRangeBeforePosition:range.location];
        if (prefix.location != NSNotFound && [prefixesToIgnore containsObject:[content substringWithRange:prefix]]) {
            // The word has a prefix to ignore
            continue;
        }
        if (prefix.location != NSNotFound) {
            
            DDLogInfo(@"Not handled command: %@ - %@", [content substringWithRange:prefix],[content substringWithRange:range]);
        }
        DDLogWarn(@"NH: %@", [content substringWithRange:range]);
        // Unknown element. Add to result
        [finalResults addObject:result];
    }
    return finalResults;
}

- (NSString *)descriptionForResultType:(NSTextCheckingType)type {
    switch (type) {
        case NSTextCheckingTypeOrthography:
            return @"Orthography";
            break;
        case NSTextCheckingTypeGrammar:
            return @"Grammer";
            break;
        case NSTextCheckingTypeSpelling:
            return @"Spelling";
            break;
            
        default:
            return @"OTHER";
            break;
    }
}

@end
