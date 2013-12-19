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
#import "NSString+PathExtension.h"
#import "GenericFilePresenter.h"
#import "CiteCompletion.h"

@interface BibFile ()
- (void)readFile;
- (void)initDefaults;
- (NSString *)pathForEncoding;
- (void) setPathAfterDecoding:(NSString *)path;
@end

@implementation BibFile

# pragma mark - Initialization, Deallocation, NSCoding
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    if (self) {
        self.lastRead = [aDecoder decodeObjectForKey:@"lastRead"];
        self.project = [aDecoder decodeObjectForKey:@"project"];
        _path = [aDecoder decodeObjectForKey:@"path"];
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

- (void)finishInitWithPath:(NSString *)absolutePath {
    [self setPathAfterDecoding:self.path];
}


- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.lastRead forKey:@"lastRead"];
    [aCoder encodeConditionalObject:self.project forKey:@"project"];
    [aCoder encodeObject:self.pathForEncoding forKey:@"path"];
}

- (void)initDefaults {
    filePresenter = [[GenericFilePresenter alloc] initWithOperationQueue:[NSOperationQueue mainQueue]];
    filePresenter.observer = self;
}

- (void)dealloc {
    DDLogVerbose(@"dealloc");
    [filePresenter terminate];
}

#pragma mark - Path Corrections

- (NSString *)pathForEncoding {
    NSString *projectFolder = [self.project.path stringByDeletingLastPathComponent];
    if ([self.path hasPrefix:projectFolder]) {
        return [self.path relativePathWithBase:projectFolder];
    } else {
        return self.path;
    }
}

- (void)setPathAfterDecoding:(NSString *)path {
    if (![path isAbsolutePath]) {
        self.path = [path absolutePathWithBase:[self.project.path stringByDeletingLastPathComponent]];
    } else {
        self.path = path;
    }
}

#pragma mark - Content Management

- (void)setPath:(NSString *)path {
    if (![_path isEqualToString:path]) {
        _path = path;
        if (_path) {
            [filePresenter setPath:_path];
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
        NSMutableArray *entries = [parser parseBibTexIn:content];
        self.entries = [[NSMutableArray alloc] initWithCapacity:entries.count];
        for (TMTBibTexEntry *entry in entries) {
            [self.entries addObject:[[CiteCompletion alloc] initWithBibEntry:entry]];
        }
    }
}


@end
