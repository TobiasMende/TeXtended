//
//  BibFile.m
//  TeXtended
//
//  Created by Tobias Mende on 01.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <TMTBibTexTools/TMTBibTexParser.h>
#import <TMTBibTexTools/TMTBibTexEntry.h>
#import <TMTHelperCollection/GenericFilePresenter.h>
#import <TMTHelperCollection/TMTLog.h>

#import "BibFile.h"
#import "CiteCompletion.h"
#import "NSString+PathExtension.h"
#import "ProjectModel.h"

LOGGING_DEFAULT_DYNAMIC

@interface BibFile ()

    - (void)readFile;

    - (void)initDefaults;

    - (NSString *)pathForEncoding;

    - (void)setPathAfterDecoding:(NSString *)path;

@end

@implementation BibFile

# pragma mark - Init & Dealloc

+ (void)initialize {
    LOGGING_LOAD
}

    - (void)dealloc
    {
        [filePresenter terminate];
    }

    - (void)finishInitWithPath:(NSString *)absolutePath
    {
        [self setPathAfterDecoding:self.path];
    }

    - (id)init
    {
        self = [super init];
        if (self) {
            [self initDefaults];
        }
        return self;
    }

    - (void)initDefaults
    {
        filePresenter = [[GenericFilePresenter alloc] initWithOperationQueue:[NSOperationQueue mainQueue]];
        filePresenter.observer = self;
        self.fileEncoding = [NSNumber numberWithLong:NSUTF8StringEncoding];
    }


#pragma mark - NSCoding Support

    - (void)encodeWithCoder:(NSCoder *)aCoder
    {
        [aCoder encodeConditionalObject:self.project forKey:@"project"];
        [aCoder encodeObject:self.pathForEncoding forKey:@"path"];
    }

    - (id)initWithCoder:(NSCoder *)aDecoder
    {
        self = [super init];
        if (self) {
            [self initDefaults];
            self.project = [aDecoder decodeObjectForKey:@"project"];
            _path = [aDecoder decodeObjectForKey:@"path"];
        }
        return self;
    }


#pragma mark - Path Corrections

    - (NSString *)pathForEncoding
    {
        if (!self.project) {
            return self.path;
        }
        NSString *projectFolder = [self.project.path stringByDeletingLastPathComponent];
        if ([self.path hasPrefix:projectFolder]) {
            return [self.path relativePathWithBase:projectFolder];
        }
        else {
            return self.path;
        }
    }

    - (void)setPathAfterDecoding:(NSString *)path
    {
        if (![path isAbsolutePath] && self.project) {
            self.path = [path absolutePathWithBase:[self.project.path stringByDeletingLastPathComponent]];
        }
        else {
            self.path = path;
        }
    }


#pragma mark - Content Management

    - (void)setPath:(NSString *)path
    {
        if (![_path isEqualToString:path]) {
            _path = path;
            if (_path) {
                [filePresenter setPath:_path];
                [self readFile];
            }
            [self willChangeValueForKey:@"name"];
            _name = [path lastPathComponent];
            [self didChangeValueForKey:@"name"];
        }
    }

    - (void)readFile
    {
        NSString *content = [self loadFileContent];

        if (content) {
            TMTBibTexParser *parser = [TMTBibTexParser new];
            NSMutableArray *entries = [parser parseBibTexIn:content];
            self.entries = [[NSMutableArray alloc] initWithCapacity:entries.count];
            for (TMTBibTexEntry *entry in entries) {
                [self.entries addObject:[[CiteCompletion alloc] initWithBibEntry:entry]];
            }
            self.lastRead = [NSDate new];
        }
    }


#pragma mark - Manipulating Contents

    - (BOOL)insertEntry:(TMTBibTexEntry *)entry
    {
        filePresenter.observer = nil;
        BOOL success = NO;
        NSString *content = [self loadFileContent];
        if (content) {
            NSString *bibtex = entry.bibtex;
            if (bibtex) {
                content = [content stringByAppendingFormat:@"\n\n%@", bibtex];
                success = [self writeFileContent:content];
            }
        }
        filePresenter.observer = self;
        [self.entries addObject:[[CiteCompletion alloc] initWithBibEntry:entry]];
        return success;
    }

    - (TMTBibTexEntry *)entryForCiteKey:(NSString *)key
    {
        for (CiteCompletion *entry in self.entries) {
            if ([entry.key.lowercaseString isEqualToString:key.lowercaseString]) {
                return entry.entry;
            }
        }
        return nil;
    }


#pragma mark - Loading & Saving

    - (NSString *)loadFileContent
    {
        NSError *error;
        NSStringEncoding encoding;
        NSString *content = [NSString stringWithContentsOfFile:self.path usedEncoding:&encoding error:&error];

        if (error) {
            DDLogError(@"Can't load bib content: %@", error.userInfo);
            return nil;
        }
        else {
            self.fileEncoding = [NSNumber numberWithUnsignedLong:encoding];
            return content;
        }
    }

    - (BOOL)writeFileContent:(NSString *)content
    {
        NSStringEncoding encoding = self.fileEncoding ? self.fileEncoding.unsignedLongValue : NSUTF8StringEncoding;
        NSError *error;

        [content writeToFile:self.path atomically:YES encoding:encoding error:&error];
        if (error) {
            DDLogError(@"Error while writing bib file: %@", error.userInfo);
            return NO;
        }
        return YES;
    }


#pragma mark - FileObserver Methods

    - (void)presentedItemDidChange
    {
        DDLogDebug(@"Item changed!");
        [self readFile];
    }

    - (void)presentedItemDidMoveToURL:(NSURL *)newURL
    {
        self.path = [newURL path];
    }

#pragma mark - Hash & Equals


    - (BOOL)isEqual:(id)other
    {
        if (other == self)
            return YES;
        if (!other || ![[other class] isEqual:[self class]])
            return NO;

        return [self isEqualToFile:other];
    }

    - (BOOL)isEqualToFile:(BibFile *)file
    {
        if (self == file)
            return YES;
        if (file == nil)
            return NO;
        if (self.path != file.path && ![self.path isEqualToString:file.path])
            return NO;
        return YES;
    }

    - (NSUInteger)hash
    {
        return [self.path hash];
    }

@end
