//
//  LatexSpellChecker.m
//  TeXtended
//
//  Created by Tobias Mende on 08.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "LatexSpellChecker.h"
#import <TMTHelperCollection/TMTLog.h>

@implementation LatexSpellChecker



- (NSInteger)requestCheckingOfString:(NSString *)stringToCheck range:(NSRange)range types:(NSTextCheckingTypes)checkingTypes options:(NSDictionary *)options inSpellDocumentWithTag:(NSInteger)tag completionHandler:(void (^)(NSInteger, NSArray *, NSOrthography *, NSInteger))callersHandler {
    
    void (^completionHandler)(NSInteger, NSArray *, NSOrthography *, NSInteger);
    
    completionHandler = ^(NSInteger sequenceNumber, NSArray *results, NSOrthography *orthography, NSInteger wordCount) {
        
        // TODO: implement spell checking here
        
        callersHandler(sequenceNumber, results, orthography, wordCount);
    };
    
    return [super requestCheckingOfString:stringToCheck range:range types:checkingTypes options:options inSpellDocumentWithTag:tag completionHandler:completionHandler];
}

@end
