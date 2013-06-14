//
//  DBLPCallbackHandler.h
//  DBLP Tool
//
//  Created by Tobias Mende on 14.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DBLPCallbackHandler <NSObject>
- (void) startedFetcheingAuthors:(NSString *)authorName;
- (void) finishedFetcheingAuthors:(NSMutableDictionary *)authors;
- (void) failedFetchingAuthors;

- (void) startedFetchingKeys:(NSString *)urlpt;
- (void) finishedFetchingKeys:(NSMutableArray *)publications;
- (void) failedFetchingKeys;
@end
