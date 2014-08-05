//
//  DBLPCallbackHandler.h
//  DBLP Tool
//
//  Created by Tobias Mende on 14.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 The DBLPCallbackHandler protocol must be implemented by classes which need to deal with instances of the DBLPInterface class.
 
 **Author:** Tobias Mende
 
 */
@protocol DBLPCallbackHandler <NSObject>

/**
 Method informs the handler that searching for a given name was started
 
 @param authorName the author's name
 */
    - (void)startedFetchingAuthors:(NSString *)authorName;

/**
 Method informs the handler that searching for a given name was finished successfully
 
 @param authors a dictionary of authors, containing the author's DBLP ID as key and the author's name as value
 */
    - (void)finishedFetchingAuthors:(NSMutableDictionary *)authors;

/**
 Method informs the receiver, that searching has failed.
 
 @param error an error object, describing the problem.
 */
    - (void)failedFetchingAuthors:(NSError *)error;

/**
 Method informs the handler that searching for a given DBLP ID was started
 
 @param urlpt the authors DBLP profile url
 */
    - (void)startedFetchingKeys:(NSString *)urlpt;

/**
 Method informs the handler that searching for a given author's DBLP ID was finished successfully
 
 @param publications a list of publications
 */
    - (void)finishedFetchingKeys:(NSMutableArray *)publications;

/**
 Method informs the receiver, that searching has failed.
 
 @param error an error object, describing the problem.
 */
    - (void)failedFetchingKeys:(NSError *)error;
@end
