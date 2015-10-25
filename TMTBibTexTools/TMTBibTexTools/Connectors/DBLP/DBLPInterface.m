//
//  DBLPHandler.m
//  DBLP Tool
//
//  Created by Tobias Mende on 14.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "DBLPInterface.h"
#import "TMTBibTexEntry.h"
#import "DBLPConfiguration.h"
#import <TMTHelperCollection/TMTLog.h>

LOGGING_DEFAULT

@interface DBLPInterface ()

- (void)finishAuthorsLoading:(NSData *)authorData;

- (void)finishKeysLoading:(NSData *)publicationData;
@end

@implementation DBLPInterface

    - (id)initWithHandler:(id <DBLPCallbackHandler>)handler
    {
        self = [super init];
        if (self) {
            _handler = handler;
            config = [DBLPConfiguration sharedInstance];
        }
        return self;
    }

    - (void)searchAuthor:(NSString *)query
    {
        const NSString *stripedQuery = [query stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSString *total = [config.server stringByAppendingFormat:@"%@%@", config.authorSearchAppendix, stripedQuery];
        NSURL *url = [NSURL URLWithString:total];
        NSURLRequest *theRequest = [NSURLRequest requestWithURL:url
                                                    cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                timeoutInterval:60.0];

        if(receiveTask) {
            [receiveTask cancel];
        }
        receiveTask = [[NSURLSession sharedSession] dataTaskWithRequest:theRequest completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
            if([self isCancelled:error]) {
                return;
            }
            if(error) {
                DDLogError(@"DBLP Connection failed: %@", error.userInfo);
                [self.handler failedFetchingAuthors:error];
            } else {
                [self finishAuthorsLoading:data];
            }
        }];
        [self.handler startedFetchingAuthors:query];
        [receiveTask resume];
    }

- (BOOL)isCancelled:(NSError *)error {
    return error && error.code == NSURLErrorCancelled;
}

- (void)finishAuthorsLoading:(NSData *)authorData {
    NSError *error;
    NSXMLDocument *xml = [[NSXMLDocument alloc] initWithData:authorData options:0 error:&error];
    NSMutableDictionary *results;
    if (error) {
        DDLogError(@"Can't fetch anything: %@", error);
        [self.handler failedFetchingAuthors:error];
    } else {
        NSArray *a = [xml nodesForXPath:@"/authors/author" error:&error];
        results = [NSMutableDictionary dictionaryWithCapacity:a.count];
        for (NSXMLElement *node in a) {
            NSString *urlpt = [[node attributeForName:@"urlpt"] stringValue];
            results[urlpt] = [node stringValue];
            [self.handler finishedFetchingAuthors:results];
        }
        if (a.count == 0) {
            [self.handler finishedFetchingAuthors:results];
        }
    }
}

- (void)finishKeysLoading:(NSData *)publicationData {
    NSError *error;
    NSXMLDocument *xml = [[NSXMLDocument alloc] initWithData:publicationData options:0 error:&error];
    NSMutableArray *results;

    if (error) {
        DDLogError(@"Can't fetch anything: %@", error);
        [self.handler failedFetchingKeys:error];
    } else {
        NSArray *a = [xml nodesForXPath:@"/dblpperson/dblpkey" error:&error];
        results = [NSMutableArray arrayWithCapacity:a.count];
        if (error) {
            DDLogError(@"Can't extract dblpkeys from xml: %@", [error userInfo]);
        }
        for (NSXMLElement *node in a) {
            NSString *personRecord = [[node attributeForName:@"type"] stringValue];
            if (!personRecord) {
                NSString *appendix = [node stringValue];
                NSString *bibUrl = [config.server stringByAppendingFormat:@"%@%@.xml", config.bibtexSearchAppendix, [appendix stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                TMTBibTexEntry *pub = [[TMTBibTexEntry alloc] initWithXMLUrl:[NSURL URLWithString:bibUrl]];
                [results addObject:pub];
            }
        }
        [self.handler finishedFetchingKeys:results];
    }
}


    - (void)publicationsForAuthor:(NSString *)urlpt
    {
        NSString *total = [config.server stringByAppendingFormat:@"%@%@/xk", config.keySearchAppendix, [urlpt stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSURL *url = [NSURL URLWithString:total];
        NSURLRequest *theRequest = [NSURLRequest requestWithURL:url
                                                    cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                timeoutInterval:60.0];

        if (receiveTask) {
            [receiveTask cancel];
        }

        NSURLSession *session = [NSURLSession sharedSession];
        receiveTask = [session dataTaskWithRequest:theRequest completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
            if([self isCancelled:error]) {
                return;
            }
            if(error) {
                DDLogError(@"DBLP Connection failed: %@", error.userInfo);
                [self.handler failedFetchingKeys:error];
            } else {
                [self finishKeysLoading:data];
            }
        }];
        [self.handler startedFetchingKeys:urlpt];
        [receiveTask resume];
    }


@end
