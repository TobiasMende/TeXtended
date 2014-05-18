//
//  Compilable.m
//  TeXtended
//
//  Created by Tobias Mende on 01.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <BibTexToolsFramework/TMTBibTexEntry.h>
#import <TMTHelperCollection/TMTLog.h>

#import "BibFile.h"
#import "Compilable.h"
#import "CompileSetting.h"
#import "TMTNotificationCenter.h"


static NSUInteger LAST_IDENTIFIER = 0;


@interface Compilable ()

    - (NSMutableArray *)convertMainDocuments:(id)docs;

/** This method coverts bibfiles from older project versions from NSSet to NSArray */
    - (NSMutableArray *)convertBibFiles:(id)bibfiles;

@end

@implementation Compilable

#pragma mark - Init, Dealloc & Copy

    - (id)copy
    {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:@[self]];
        id copied = [NSKeyedUnarchiver unarchiveObjectWithData:data][0];

        return copied;
    }

    - (void)dealloc
    {
        [TMTNotificationCenter removeCenterForCompilable:self];
    }

    - (void)finishInitWithPath:(NSString *)absolutePath
    {
    }

    - (id)init
    {
        self = [super init];
        if (self) {
            _identifier = [NSString stringWithFormat:@"id%ld", LAST_IDENTIFIER++];
            self.hasFinalCompiler = NO;
            self.hasDraftCompiler = NO;
            self.hasLiveCompiler = NO;
        }
        return self;
    }


#pragma mark - NSCoding Support

    - (void)encodeWithCoder:(NSCoder *)aCoder
    {
        if (self.hasDraftCompiler) {
            [aCoder encodeObject:self.draftCompiler forKey:@"draftCompiler"];
        }
        if (self.hasLiveCompiler) {
            [aCoder encodeObject:self.liveCompiler forKey:@"liveCompiler"];
        }
        if (self.hasFinalCompiler) {
            [aCoder encodeObject:self.finalCompiler forKey:@"finalCompiler"];
        }
        [aCoder encodeObject:_mainDocuments forKey:@"mainDocuments"];
        [aCoder encodeObject:_encoding forKey:@"encoding"];
        [aCoder encodeObject:_bibFiles forKey:@"bibFiles"];
    }

    - (id)initWithCoder:(NSCoder *)aDecoder
    {
        self = [super init];
        if (self) {
            _identifier = [NSString stringWithFormat:@"id%ld", LAST_IDENTIFIER++];
            self.draftCompiler = [aDecoder decodeObjectForKey:@"draftCompiler"];
            self.finalCompiler = [aDecoder decodeObjectForKey:@"finalCompiler"];
            self.liveCompiler = [aDecoder decodeObjectForKey:@"liveCompiler"];
            self.encoding = [aDecoder decodeObjectForKey:@"encoding"];
            self.bibFiles = [self convertBibFiles:[aDecoder decodeObjectForKey:@"bibFiles"]];

            self.hasFinalCompiler = self.finalCompiler != nil;
            self.hasDraftCompiler = self.draftCompiler != nil;
            self.hasLiveCompiler = self.liveCompiler != nil;

            @try {
                NSArray *mainDocuments = [self convertMainDocuments:[aDecoder decodeObjectForKey:@"mainDocuments"]];
                if (mainDocuments && mainDocuments.count > 0) {
                    self.mainDocuments = mainDocuments;
                }
            }
            @catch (NSException *exception) {
                DDLogVerbose(@"Invalid mainDocuments set. Exception: %@", exception);
            }
        }
        return self;
    }


#pragma mark - Comparision Methods

    - (BOOL)isEqual:(id)object
    {
        if (![object isKindOfClass:[Compilable class]]) {
            return NO;
        }
        Compilable *other = (Compilable *) object;
        return [self.path isEqualTo:other.path];
    }


#pragma mark - Converter Methods

    - (NSMutableArray *)convertBibFiles:(id)bibfiles
    {
        if ([bibfiles isKindOfClass:[NSSet class]]) {
            NSMutableArray *finalBibfiles = [NSMutableArray arrayWithCapacity:[(NSSet *) bibfiles count]];
            for (id b in bibfiles) {
                [finalBibfiles addObject:b];
            }
            return finalBibfiles;
        }
        else {
            return bibfiles;
        }
    }

    - (NSMutableArray *)convertMainDocuments:(id)docs
    {
        if ([docs isKindOfClass:[NSSet class]]) {
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:[docs count]];
            for (id obj in docs) {
                [array addObject:obj];
            }
            return array;
        }
        return docs;
    }


#pragma mark - Getter

    - (NSDictionary *)fileSystemAttributes
    {
        return [[NSFileManager defaultManager] attributesOfItemAtPath:self.path error:NULL];
    }

    - (NSDate *)lastChanged
    {
        return [self.fileSystemAttributes fileModificationDate];
    }

    - (Compilable *)mainCompilable
    {
        return self;
    }

    - (ProjectModel *)project
    {
        return nil;
    }


#pragma mark - Setter

    - (void)setHasLiveCompiler:(BOOL)hasLiveCompiler
    {
        if (hasLiveCompiler != _hasLiveCompiler) {
            _hasLiveCompiler = hasLiveCompiler;
        }
        [self updateCompileSettingBindings:live];
    }

    - (void)setHasDraftCompiler:(BOOL)hasDraftCompiler
    {
        if (hasDraftCompiler != _hasDraftCompiler) {
            _hasDraftCompiler = hasDraftCompiler;
        }
        [self updateCompileSettingBindings:draft];
    }

    - (void)setHasFinalCompiler:(BOOL)hasFinalCompiler
    {
        if (hasFinalCompiler != _hasFinalCompiler) {
            _hasFinalCompiler = hasFinalCompiler;
        }
        [self updateCompileSettingBindings:final];
    }

#pragma mark Compile Setting Handling

    - (void)updateCompileSettingBindings:(CompileMode)mode
    {
        switch (mode) {
            case live :
                if (self.hasLiveCompiler) {
                    [self.liveCompiler unbindAll];
                }
                else {
                    self.liveCompiler = [CompileSetting defaultLiveCompileSetting];
                }
                break;
            case draft :
                if (self.hasDraftCompiler) {
                    [self.draftCompiler unbindAll];
                }
                else {
                    self.draftCompiler = [CompileSetting defaultDraftCompileSetting];
                }
                break;
            case final :
                if (self.hasFinalCompiler) {
                    [self.finalCompiler unbindAll];
                }
                else {
                    self.finalCompiler = [CompileSetting defaultFinalCompileSetting];
                }
                break;
            default :
                break;
        }
    }


#pragma mark - Collection Helpers

    - (DocumentModel *)modelForTexPath:(NSString *)path
    {
        return [self modelForTexPath:path byCreating:YES];
    }

    - (DocumentModel *)modelForTexPath:(NSString *)path byCreating:(BOOL)shouldCreate
    {
        DDLogError(@"This is not my job. Ask ProjectModel or DocumentModel instead.");
        return nil;
    }


#pragma mark - MainDocument Collection Helpers

    - (void)addMainDocuments:(NSArray *)values
    {
        if (!self.mainDocuments) {
            self.mainDocuments = [NSArray new];
        }
        self.mainDocuments = [self.mainDocuments arrayByAddingObjectsFromArray:values];
    }

    - (void)removeMainDocuments:(NSArray *)values
    {
        NSMutableArray *tmp = [self.mainDocuments mutableCopy];

        for (NSObject *obj in values) {
            [tmp removeObject:obj];
        }
        self.mainDocuments = tmp;
    }

    - (void)removeMainDocument:(DocumentModel *)value
    {
        NSMutableArray *tmp = [self.mainDocuments mutableCopy];

        [tmp removeObject:value];
        self.mainDocuments = tmp;
    }

    - (void)addMainDocument:(DocumentModel *)value
    {
        if ([self.mainDocuments containsObject:value]) {
            return;
        }
        if (!self.mainDocuments) {
            self.mainDocuments = [NSArray new];
        }
        self.mainDocuments = [self.mainDocuments arrayByAddingObject:value];
    }


#pragma mark BibFile Collection Helpers

    - (void)addBibFileWithPath:(NSString *)path
    {
        BibFile *file = [BibFile new];

        file.project = self;
        file.path = path;
        [self willChangeValueForKey:@"bibFiles"];
        [self.bibFiles addObject:file];
        [self didChangeValueForKey:@"bibFiles"];
    }

    - (void)removeBibFileWithIndex:(NSUInteger)index
    {
        [self willChangeValueForKey:@"bibFiles"];
        [self.bibFiles removeObjectAtIndex:index];
        [self didChangeValueForKey:@"bibFiles"];
    }

    - (TMTBibTexEntry *)findBibTexEntryForKey:(NSString *)key containingDocument:(NSString * __autoreleasing *)path
    {
        TMTBibTexEntry *citeEntry = nil;

        for (BibFile *file in self.bibFiles) {
            citeEntry = [file entryForCiteKey:key];
            if (citeEntry) {
                if (path) {
                    *path = file.path;
                }
                break;
            }
        }
        return citeEntry;
    }

@end
