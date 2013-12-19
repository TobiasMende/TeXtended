//
//  Publication.m
//  DBLP Tool
//
//  Created by Tobias Mende on 14.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "TMTBibTexEntry.h"
#import "DBLPConfiguration.h"

@interface TMTBibTexEntry ()
/** Method for starting asynchronous DBLP information fetching 
 
 @param url the DBLP URL
 */
- (void) parseDocument:(NSURL *)url;

/**
 Method for fetching general bibliography informations like title, type and mdate from the provided document
 
 @param doc the XML document
 */
- (void) fetchGeneralInfos:(NSXMLDocument*)doc;

/**
 Generates the dictionary representation of the provided document
 
 @param doc the XML document
 */
- (void) generateDictionary:(NSXMLDocument*)doc;

/** Method for generating the bing of a new bibtex line (@\tkey={@)
 
 @param key the name of the entry
 @return The line begining
 */
- (NSString*)lineBeginFor:(NSString *)key;

/**
 Method for generating a new line in the bibtex document
 @param key the name of the entry
 @param value the value of the entry
 
 @return the entire line
 */
- (NSString*)bibtexLineFor:(NSString *)key andValue:(NSString*)value;

/**
 Some values need to be modified for better quality of the bibtex output. This method modifies the values for some key
 
 @param value the value that might be modified
 @param key the name of the value
 
 @return the possibly modified value.
 */
- (NSString*)modifyValue:(NSString*) value forKey:(NSString*) key;
@end
@implementation TMTBibTexEntry

#pragma mark - Initialization
- (id)initWithXMLUrl:(NSURL *)url {
    self = [self init];
    if (self) {
        [self parseDocument:url];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        self.dictionary = [NSMutableDictionary new];
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

#pragma mark - Networking

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
    }

}

# pragma mark Information Extraction

- (void)fetchGeneralInfos:(NSXMLDocument *)doc {
    NSError *error;
    NSArray *array = [doc nodesForXPath:@"/dblp/*" error:&error];
    NSXMLElement *e = [array objectAtIndex:0];
    [self generateDictionary:doc];
    self.xml = e;
    self.type = e.name;
    self.key = [@"DBLP:" stringByAppendingString:[[e attributeForName:@"key"] stringValue]];
    self.mdate = [NSDate dateWithString:[[e attributeForName:@"mdate"] stringValue]];
    
}

- (void)generateDictionary:(NSXMLDocument *)doc {
    NSError *error;
    NSArray *array = [doc nodesForXPath:@"/dblp/*/*" error:&error];
    if (error) {
        NSLog(@"Can't generate dictionary");
    } else {
        self.dictionary = [NSMutableDictionary dictionaryWithCapacity:array.count];
        for(NSXMLElement *e in array) {
            [self willChangeValueForKey:e.name];
            if ([e.name isEqualToString:@"author"]) {
                NSMutableSet *authors = [self.dictionary objectForKey:e.name];
                if (authors) {
                    [authors addObject:e.stringValue];
                    self.author = [self.author stringByAppendingFormat:@" and %@", e.stringValue];
                } else {
                    authors = [NSMutableSet setWithObject:e.stringValue];
                    [self.dictionary setObject:authors forKey:e.name];
                    self.author = e.stringValue;
                }
            } else {
                [self setValue:[self modifyValue:e.stringValue forKey:e.name] forKey:e.name];
            }
            [self didChangeValueForKey:e.name];
        }
    }
}

- (NSString *)bibtex{
    if (!self.dictionary) {
        NSLog(@"Can't generate bibtex");
    } else {
        NSMutableString *entry = [[NSMutableString alloc] init];
        [entry appendFormat:@"@%@{%@,\n", self.type, self.key];
        if(self.author) {
            [entry appendString:[self bibtexLineFor:@"author" andValue:self.author]];
        }
        if (self.title) {
            [entry appendString:[self bibtexLineFor:@"title" andValue:self.title]];
        }
            for(NSString *key in self.dictionary.keyEnumerator) {
                if (![key isEqualToString:@"author"]) {
                    [entry appendString:[self bibtexLineFor:key andValue:[self.dictionary objectForKey:key]]];
                }
            }
        [entry appendString:@"}"];
        return entry;
    }
    return nil;
}


- (NSString *)modifyValue:(NSString *)value forKey:(NSString *)key {
    NSString *result;
    if ([key isEqualToString:@"url"] || [key isEqualToString:@"crossref"]) {
        result = [[DBLPConfiguration sharedInstance].server stringByAppendingString:value];
    } else {
        result = value;
    }
    return result;
    
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

- (id)valueForUndefinedKey:(NSString *)key {
    return [self.dictionary objectForKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    [self.dictionary setObject:value forKey:key];
}


# pragma mark - Sorting

- (NSComparisonResult)compare:(TMTBibTexEntry *)other {
    NSComparisonResult result = [self.author caseInsensitiveCompare:other.author];
    if (result == NSOrderedSame) {
        result = [self.title caseInsensitiveCompare:other.title];
    }
    if (result == NSOrderedSame) {
        result = [self.key caseInsensitiveCompare:other.key];
    }
    return result;
}

@end
