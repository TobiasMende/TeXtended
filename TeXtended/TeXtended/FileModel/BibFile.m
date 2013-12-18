//
//  BibFile.m
//  TeXtended
//
//  Created by Tobias Mende on 01.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "BibFile.h"
#import "ProjectModel.h"
#import "TMTLog.h"
#import "TMTBibTexParser.h"
#import "TMTBibTexEntry.h"

@interface BibFile ()
- (void)readFile;
- (void)initDefaults;
@end

@implementation BibFile

# pragma mark - Initialization, Deallocation, NSCoding
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    if (self) {
        self.lastRead = [aDecoder decodeObjectForKey:@"lastRead"];
        self.project = [aDecoder decodeObjectForKey:@"project"];
        self.path = [aDecoder decodeObjectForKey:@"path"];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self initDefaults];
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.lastRead forKey:@"lastRead"];
    [aCoder encodeConditionalObject:self.project forKey:@"project"];
    [aCoder encodeObject:self.path forKey:@"path"];
}

- (void)initDefaults {
    _presentedItemOperationQueue = [NSOperationQueue mainQueue];
    [NSFileCoordinator addFilePresenter:self];
}

- (void)dealloc {
    [NSFileCoordinator removeFilePresenter:self];
}

#pragma mark - Content Management

- (void)setPath:(NSString *)path {
    if (![_path isEqualToString:path]) {
        if (_path) {
            
        }
        _path = path;
        if (_path) {
            _presentedItemURL = [NSURL fileURLWithPath:_path];
            [self readFile];
            
            
        }
    }
}


- (void)presentedItemDidChange {
    DDLogWarn(@"Item changed!");
    [self readFile];
}

- (void)presentedItemDidMoveToURL:(NSURL *)newURL {
    self.path = [newURL path];
}

- (void)readFile {
    NSError *error;
    NSString *content = [NSString stringWithContentsOfFile:self.path usedEncoding:NULL error:&error];
    if (error) {
        DDLogError(@"Can't load bib content: %@", error.userInfo);
    } else {
        TMTBibTexParser *parser = [TMTBibTexParser new];
        self.entries = [parser parseBibTexIn:content];
        [self.entries sortUsingSelector:@selector(compare:)];
    }
}


@end
