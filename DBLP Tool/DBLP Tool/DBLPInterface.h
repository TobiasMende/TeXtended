//
//  DBLPHandler.h
//  DBLP Tool
//
//  Created by Tobias Mende on 14.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBLPCallbackHandler.h"

@class DBLPConfiguration;

/**
 This class provides an interface to a DBLP database and handles search requests for authors and bib entries.
 
 **Author:** Tobias Mende
 
 */
@interface DBLPInterface : NSObject <NSURLConnectionDataDelegate, NSXMLParserDelegate>
    {
        NSMutableData *receivedAuthorData;

        NSMutableData *receivedKeyData;

        NSURLConnection *authorConnection;

        NSURLConnection *dblpKeyConnection;

        DBLPConfiguration *config;

    }

/**
 Method for initializing a new DBLP interface.
 
 @param handler the callback handler
 
 @return a new instance
 */
    - (id)initWithHandler:(id <DBLPCallbackHandler>)handler;

/**
 Method for starting the author search.
 
 *Note* that the searching is performed asynchronous. Therefore, this method doesn't return anything but one of the DBLPCallbackHandler's methods will be called after finishing the request.
 
 @param query the search query
 */
    - (void)searchAuthor:(NSString *)query;

/**
 Method for starting the publications search.
 
 *Note* that the searching is performed asynchronous. Therefore, this method doesn't return anything but one of the DBLPCallbackHandler's methods will be called after finishing the request.
 
 @param urlpt the authors DBLP url
 */
    - (void)publicationsForAuthor:(NSString *)urlpt;


/** The callback handler connected to this interface */
    @property id <DBLPCallbackHandler> handler;

@end
