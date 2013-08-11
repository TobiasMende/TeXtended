//
//  DBLPHandler.m
//  DBLP Tool
//
//  Created by Tobias Mende on 14.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "DBLPInterface.h"
#import "DBLPPublication.h"
#import "DBLPConfiguration.h"

@interface DBLPInterface ()
- (void)finishAuthorsLoading;
- (void)finishKeysLoading;
@end

@implementation DBLPInterface
- (id)initWithHandler:(id<DBLPCallbackHandler>)handler {
    self = [super init];
    if (self) {
        _handler = handler;
        config = [DBLPConfiguration sharedInstance];
    }
    return self;
}

- (void)searchAuthor:(NSString *)query {
    NSString *total = [config.server stringByAppendingFormat:@"%@%@", config.authorSearchAppendix, [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURL *url  = [NSURL URLWithString:total];
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:url
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    if (authorConnection) {
        [authorConnection cancel];
    }
    authorConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (authorConnection) {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        [self.handler startedFetchingAuthors:query];
        receivedAuthorData = [NSMutableData data];
    } else {
        NSError *error = [NSError errorWithDomain:@"DBLP Connection failed" code:0 userInfo:[NSDictionary dictionaryWithObject:@"DBLP Connection failed" forKey:@"description"]];
        [self.handler failedFetchingAuthors:error];
        // Inform the user that the connection failed.
    }
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if ([connection isEqualTo:authorConnection]) {
        [receivedAuthorData setLength:0];
    } else if ([connection isEqualTo:dblpKeyConnection]) {
        [receivedKeyData setLength:0];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if ([connection isEqualTo:authorConnection]) {
        [receivedAuthorData appendData:data];
    } else if ([connection isEqualTo:dblpKeyConnection]) {
        [receivedKeyData appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if ([connection isEqualTo:authorConnection]) {
        authorConnection = nil;
        [self finishAuthorsLoading];
    } else if ([connection isEqualTo:dblpKeyConnection]) {
        [self finishKeysLoading];
    }
}

- (void)finishAuthorsLoading {
    //NSLog(@"Succeeded! Received %ld bytes of data",(unsigned long)[receivedAuthorData length]);
    NSError *error;
    NSXMLDocument *xml = [[NSXMLDocument alloc] initWithData:receivedAuthorData options:0 error:&error];
    NSMutableDictionary *results;
    if (error) {
        NSLog(@"Can't fetch anything");
        [self.handler failedFetchingAuthors:error];
    } else {
        NSArray *a = [xml nodesForXPath:@"/authors/author" error:&error];
        results = [NSMutableDictionary dictionaryWithCapacity:a.count];
        for (NSXMLElement *node in a) {
            NSString *urlpt = [[node attributeForName:@"urlpt"] stringValue];
            [results setObject:[node stringValue] forKey:urlpt];
            [self.handler finishedFetchingAuthors:results];
        }
        if (a.count == 0) {
            [self.handler finishedFetchingAuthors:results];
        }
    }
}

- (void)finishKeysLoading {
    //NSLog(@"Succeeded! Received %ld bytes of data",(unsigned long)[receivedKeyData length]);
    NSError *error;
    //NSLog(@"Keys-Result: %@", [[NSString alloc] initWithData:receivedKeyData encoding:NSUTF8StringEncoding]);
    NSXMLDocument *xml = [[NSXMLDocument alloc] initWithData:receivedKeyData options:0 error:&error];
    NSMutableArray *results;
    
    if (error) {
        NSLog(@"Can't fetch anything");
        [self.handler failedFetchingKeys:error];
    } else {
        NSArray *a = [xml nodesForXPath:@"/dblpperson/dblpkey" error:&error];
        results = [NSMutableArray arrayWithCapacity:a.count];
        if (error) {
            NSLog(@"%@", [error userInfo]);
        }
        for (NSXMLElement *node in a) {
            NSString *personRecord = [[node attributeForName:@"type"] stringValue];
            if (!personRecord) {
                NSString *appendix = [node stringValue];
                NSString *bibUrl = [config.server stringByAppendingFormat:@"%@%@.xml", config.bibtexSearchAppendix, [appendix stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                DBLPPublication *pub = [[DBLPPublication alloc] initWithXMLUrl:[NSURL URLWithString:bibUrl]];
                [results addObject:pub];
            } 
        }
        [self.handler finishedFetchingKeys:results];
    }
}


- (void)publicationsForAuthor:(NSString *)urlpt {
    NSString *total = [config.server stringByAppendingFormat:@"%@%@/xk", config.keySearchAppendix, [urlpt stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURL *url = [NSURL URLWithString:total];
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:url
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    if (dblpKeyConnection) {
        [dblpKeyConnection cancel];
    }
    dblpKeyConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (dblpKeyConnection) {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        [self.handler startedFetchingKeys:urlpt];
        receivedKeyData = [NSMutableData data];
    } else {
        NSError *error = [NSError errorWithDomain:@"DBLP Connection failed" code:0 userInfo:[NSDictionary dictionaryWithObject:@"DBLP Connection failed" forKey:@"description"]];
        [self.handler failedFetchingKeys:error];
        // Inform the user that the connection failed.
    }
}



@end
