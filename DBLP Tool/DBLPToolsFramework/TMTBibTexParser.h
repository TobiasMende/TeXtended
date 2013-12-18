//
//  BibTexParser.h
//  DBLP Tool
//
//  Created by Tobias Mende on 18.12.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMTBibTexParser : NSObject {
    NSScanner *scanner;
    NSMutableDictionary *strings;
}

- (NSMutableArray *)parseBibTexIn:(NSString *)content;

@end
