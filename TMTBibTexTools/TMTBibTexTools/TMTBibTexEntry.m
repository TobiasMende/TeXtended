//
//  Publication.m
//  DBLP Tool
//
//  Created by Tobias Mende on 14.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "TMTBibTexEntry.h"
#import "DBLPConfiguration.h"
#import <TMTHelperCollection/TMTLog.h>

LOGGING_DEFAULT

@interface TMTBibTexEntry ()

/** Method for starting asynchronous DBLP information fetching
 
 @param url the DBLP URL
 */
    - (void)parseDocument:(NSURL *)url;

/**
 Method for fetching general bibliography informations like title, type and mdate from the provided document
 
 @param doc the XML document
 */
    - (void)fetchGeneralInfos:(NSXMLDocument *)doc;

/**
 Generates the dictionary representation of the provided document
 
 @param doc the XML document
 */
    - (void)generateDictionary:(NSXMLDocument *)doc;

/** Method for generating the bing of a new bibtex line (@\tkey={@)
 
 @param key the name of the entry
 @return The line begining
 */
    - (NSString *)lineBeginFor:(NSString *)key;

/**
 Method for generating a new line in the bibtex document
 @param key the name of the entry
 @param value the value of the entry
 
 @return the entire line
 */
    - (NSString *)bibtexLineFor:(NSString *)key andValue:(NSString *)value;

/**
 Some values need to be modified for better quality of the bibtex output. This method modifies the values for some key
 
 @param value the value that might be modified
 @param key the name of the value
 
 @return the possibly modified value.
 */
    - (NSString *)modifyValue:(NSString *)value forKey:(NSString *)key;
@end

@implementation TMTBibTexEntry

#pragma mark - Initialization
    - (id)initWithXMLUrl:(NSURL *)url
    {
        self = [self init];
        if (self) {
            [self parseDocument:url];
        }
        return self;
    }

    - (id)init
    {
        self = [super init];
        if (self) {
            self.dictionary = [NSMutableDictionary new];
        }
        return self;
    }

- (void)parseDocumentData:(NSData *)data
{
    NSError *parseError;
    NSXMLDocument *doc = [[NSXMLDocument alloc] initWithData:data options:0 error:&parseError];
    if (parseError) {
        DDLogError(@"Can't parse doc. %@", [parseError userInfo]);
    } else {
        [self fetchGeneralInfos:doc];
    }
}

- (void)parseDocument:(NSURL *)url
    {
        NSURLRequest *theRequest = [NSURLRequest requestWithURL:url
                                                    cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                timeoutInterval:60.0];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:theRequest completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
            if(error) {
                DDLogError(@"Failed to request the data: %@", error.userInfo);
            } else {
                [self parseDocumentData:data];
            }
        }];
        
        [task resume];
    }

# pragma mark Information Extraction

    - (void)fetchGeneralInfos:(NSXMLDocument *)doc
    {
        NSError *error;
        NSArray *array = [doc nodesForXPath:@"/dblp/*" error:&error];
        NSXMLElement *e = array[0];
        [self generateDictionary:doc];
        self.xml = e;
        self.type = e.name;
        self.key = [@"DBLP:" stringByAppendingString:[[e attributeForName:@"key"] stringValue]];
        
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        self.mdate = [dateFormatter dateFromString:[[e attributeForName:@"mdate"] stringValue]];

    }

    - (void)generateDictionary:(NSXMLDocument *)doc
    {
        NSError *error;
        NSArray *array = [doc nodesForXPath:@"/dblp/*/*" error:&error];
        if (error) {
            DDLogError(@"Can't generate dictionary: %@", error);
        } else {
            self.dictionary = [NSMutableDictionary dictionaryWithCapacity:array.count];
            for (NSXMLElement *e in array) {
                [self willChangeValueForKey:e.name];
                if ([e.name isEqualToString:@"author"]) {
                    NSMutableSet *authors = (self.dictionary)[e.name];
                    if (authors) {
                        [authors addObject:e.stringValue];
                        self.author = [self.author stringByAppendingFormat:@" and %@", e.stringValue];
                    } else {
                        authors = [NSMutableSet setWithObject:e.stringValue];
                        (self.dictionary)[e.name] = authors;
                        self.author = e.stringValue;
                    }
                } else {
                    [self setValue:[self modifyValue:e.stringValue forKey:e.name] forKey:e.name];
                }
                [self didChangeValueForKey:e.name];
            }
        }
    }

    - (NSString *)bibtex
    {
        if (!self.dictionary) {
            DDLogError(@"Can't generate bibtex (dictionary is nil)");
        } else {
            NSMutableString *entry = [[NSMutableString alloc] init];
            [entry appendFormat:@"@%@{%@,\n", self.type, self.key];
            if (self.author) {
                [entry appendString:[self bibtexLineFor:@"author" andValue:self.author]];
            }
            if (self.title) {
                [entry appendString:[self bibtexLineFor:@"title" andValue:self.title]];
            }
            for (NSString *key in self.dictionary.keyEnumerator) {
                if (![key isEqualToString:@"author"]) {
                    [entry appendString:[self bibtexLineFor:key andValue:(self.dictionary)[key]]];
                }
            }
            [entry appendString:@"}"];
            return entry;
        }
        return nil;
    }


    - (NSString *)modifyValue:(NSString *)value forKey:(NSString *)key
    {
        NSString *result;
        if ([key isEqualToString:@"url"] || [key isEqualToString:@"crossref"]) {
            result = [[DBLPConfiguration sharedInstance].server stringByAppendingString:value];
        } else {
            result = value;
        }
        return result;

    }

    - (NSString *)bibtexLineFor:(NSString *)key andValue:(NSString *)value
    {
        NSString *LINE_END = @"},\n";
        return [NSString stringWithFormat:@"%@%@%@", [self lineBeginFor:key], value, LINE_END];
    }

    - (NSString *)lineBeginFor:(NSString *)key
    {
        NSMutableString *space = [[NSMutableString alloc] init];
        for (NSUInteger i = key.length ; i < 10 ; i++) {
            [space appendString:@" "];
        }
        return [NSString stringWithFormat:@"\t%@%@=\t{", key, space];
    }

    - (id)valueForUndefinedKey:(NSString *)key
    {
        return (self.dictionary)[key];
    }

    - (void)setValue:(id)value forUndefinedKey:(NSString *)key
    {
        (self.dictionary)[key] = value;
    }


# pragma mark - Sorting

    - (NSComparisonResult)compare:(TMTBibTexEntry *)other
    {
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
