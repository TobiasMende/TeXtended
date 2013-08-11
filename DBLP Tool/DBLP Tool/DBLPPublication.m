//
//  Publication.m
//  DBLP Tool
//
//  Created by Tobias Mende on 14.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "DBLPPublication.h"

@interface DBLPPublication ()
- (void) parseDocument:(NSURL *)url;
- (void) fetchGeneralInfos:(NSXMLDocument*)doc;
- (void) fetchAuthors:(NSXMLDocument*)doc;
- (void) generateBibtex:(NSXMLDocument*)doc;
- (NSString*)lineBeginFor:(NSString *)key;
- (NSString*)bibtexLineFor:(NSString *)key andValue:(NSString*)value;
@end
@implementation DBLPPublication
- (id)initWithXMLUrl:(NSURL *)url {
    self = [super init];
    if (self) {
        [self parseDocument:url];
    }
    return self;
}

- (void)parseDocument:(NSURL *)url {
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:url
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if (connection) {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        receivedData = [NSMutableData data];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
        [receivedData setLength:0];

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
        [receivedData appendData:data];

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSError *error;
    NSXMLDocument *doc = [[NSXMLDocument alloc] initWithData:receivedData options:0 error:&error];
    if (error) {
        NSLog(@"Can't parse doc. %@", [error userInfo]);
    } else {
        [self fetchGeneralInfos:doc];
        [self fetchAuthors:doc];
        [self generateBibtex:doc];
    }

}

- (void)fetchGeneralInfos:(NSXMLDocument *)doc {
    NSError *error;
    NSArray *array = [doc nodesForXPath:@"/dblp/*" error:&error];
    NSXMLElement *e = [array objectAtIndex:0];
    self.xml = e;
    self.type = e.name;
    self.key = [@"DBLP:" stringByAppendingString:[[e attributeForName:@"key"] stringValue]];
    self.mdate = [NSDate dateWithString:[[e attributeForName:@"mdate"] stringValue]];
    NSArray *titleNodes = [e nodesForXPath:@"title" error:&error];
    if (error) {
        NSLog(@"DBLPPublication: %@", error.userInfo);
    } else if(titleNodes.count >0){
        NSXMLElement *titleElement = [titleNodes objectAtIndex:0];
        self.title = titleElement.stringValue;
    }
    
}

- (void)fetchAuthors:(NSXMLDocument *)doc {
    NSError *error;
     NSArray *array = [doc nodesForXPath:@"/dblp/*/author" error:&error];
    self.authors = [NSMutableArray arrayWithCapacity:array.count];
    if (error) {
        NSLog(@"Can't fetch authors. %@", [error userInfo]);
    }
    for (NSXMLElement *element in array) {
        NSString *name = [element stringValue];
        if (name && name.length >0) {
            [self.authors addObject:name];
        }
    }
}

- (void)generateBibtex:(NSXMLDocument *)doc {
    NSMutableString *entry = [[NSMutableString alloc] init];
    [entry appendFormat:@"@%@{%@,\n", self.type, self.key];
    
    NSError *error;
    NSArray *array = [doc nodesForXPath:@"/dblp/*/*" error:&error];
    if (error) {
        NSLog(@"Can't generate bibtex");
    } else {
        if (self.authors && self.authors.count > 0) {
            NSMutableString *authors = [[NSMutableString alloc] init];
            for (NSString *author in self.authors) {
                [authors appendFormat:@"%@ and ", author];
            }
            [authors deleteCharactersInRange:NSMakeRange(authors.length-5, 5)];
            [entry appendString:[self bibtexLineFor:@"author" andValue:authors]];
        }
        for(NSXMLElement *e in array) {
            if (![e.name isEqualToString:@"author"]) {
                [entry appendString:[self bibtexLineFor:e.name andValue:e.stringValue]];
            }
        }
    }
[entry appendString:@"}"];
self.bibtex = entry;
}
- (NSString *)bibtexLineFor:(NSString *)key andValue:(NSString *)value {
    NSString *LINE_END = @"},\n";
    return [NSString stringWithFormat:@"%@%@%@",[self lineBeginFor:key], value, LINE_END];
}

- (NSString *)lineBeginFor:(NSString *)key {
    NSMutableString *space = [[NSMutableString alloc] init];
    for(NSUInteger i = key.length; i < 10; i++) {
        [space appendString:@" "];
    }
    return [NSString stringWithFormat:@"\t%@%@=\t{", key, space];
}
@end
