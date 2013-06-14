//
//  DBLPHandler.h
//  DBLP Tool
//
//  Created by Tobias Mende on 14.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBLPCallbackHandler.h"
@interface DBLPInterface : NSObject<NSURLConnectionDataDelegate, NSXMLParserDelegate> {
    NSString *dblpUrl;
    NSString *authorSearchAppendix;
    NSString *keySearchAppendix;
    NSString *bibtexSearchAppendix;
    NSMutableData *receivedAuthorData;
    NSMutableData *receivedKeyData;
    NSURLConnection *authorConnection;
    NSURLConnection *dblpKeyConnection;
}
- (id) initWithHandler:(id<DBLPCallbackHandler>)handler;
- (void) searchAuthor:(NSString*) query;
- (void) publicationsForAuthor:(NSString*) urlpt;

@property id<DBLPCallbackHandler> handler;

@end
