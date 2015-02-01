//
//  DocumentModel.m
//  TeXtended
//
//  Created by Tobias Mende on 01.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <TMTHelperCollection/TMTLog.h>
#import <TMTHelperCollection/GenericFilePresenter.h>

#import "BibFile.h"
#import "CompileSetting.h"
#import "Constants.h"
#import "DocumentModel.h"
#import "NSString+PathExtension.h"
#import "OutlineExtractor.h"
#import "ProjectModel.h"
#import "TrackingMessage.h"
#import <TMTHelperCollection/FileObserver.h>
#import <TMTHelperCollection/NSSet+TMTSerialization.h>
#import <OTMXAttribute/OTMXAttribute.h>

LOGGING_DEFAULT_DYNAMIC


static const NSArray *GENERATOR_TYPES_TO_USE;

@implementation __DocumentModelProjectSyncState

    + (__DocumentModelProjectSyncState *)fullyUnsynced
    {
        return [self new];
    }

@end

@interface DocumentModel ()

    - (void)initDefaults;
    - (void)initSingleDocumentDefaults;

    - (void)updateMessages:(NSArray *)messages;

    - (void)mainDocumentsMessagesDidChange:(NSNotification *)note;

    - (void)initProjectSyncState;

    - (void)unsyncProjectState;

- (void)saveTextSpecificXAttributes;
- (void)loadTextSpecificXAttributes;
- (void)saveModelSpecificXAttributes;
- (void)loadModelSpecificXAttributes;

    @property __DocumentModelProjectSyncState *__projectSyncState;

@end

@implementation DocumentModel

#pragma mark - Init & Dealloc


    - (void)dealloc
    {
        DDLogTrace(@"%@", self.texPath);
        [_filePresenter terminate];
        if (self.texPath && [[NSFileManager defaultManager] fileExistsAtPath:self.texPath]) {
            [self saveModelSpecificXAttributes];
        }
        [self unbind:@"liveCompile"];
        [self unbind:@"openOnExport"];
        [self unsyncProjectState];
    }

    - (void)projectModelIsDeallocating
    {
        [self unsyncProjectState];
        self.project = nil;
    }

    - (void)unsyncProjectState
    {
        if (self.project) {
            if (___projectSyncState.bibFiles) {
                @try {
                    DDLogDebug(@"%@: unsync bibfiles", self);
                    [self.project removeObserver:self forKeyPath:@"bibFiles"];
                }
                @catch (NSException *exception) {
                    DDLogWarn(@"Can't remove bibFiles observer: %@", exception.reason);
                }
            }
            if (___projectSyncState.mainDocuments) {
                @try {
                    DDLogDebug(@"%@: unsync mainDocuments", self);
                    [self.project removeObserver:self forKeyPath:@"mainDocuments"];
                }
                @catch (NSException *exception) {
                    DDLogWarn(@"Can't remove mainDocuments observer: %@", exception.reason);
                }
            }
            if (___projectSyncState.encoding) {
                @try {
                    DDLogDebug(@"%@: unsync encoding", self);
                    [self.project removeObserver:self forKeyPath:@"encoding"];
                }
                @catch (NSException *exception) {
                    DDLogWarn(@"Can't remove encoding observer: %@", exception.reason);
                }
            }
        }
        ___projectSyncState = nil;

    }

    - (void)finishInitWithPath:(NSString *)absolutePath
    {
        if (self.pdfPath) {
            self.pdfPath = [self.pdfPath absolutePathWithBase:[absolutePath stringByDeletingLastPathComponent]];
        }

        if (self.texPath) {
            self.texPath = [self.texPath absolutePathWithBase:[absolutePath stringByDeletingLastPathComponent]];
        }
        [self updateCompileSettingBindings:live];
        [self updateCompileSettingBindings:draft];
        [self updateCompileSettingBindings:final];
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
        _texIdentifier = [self.identifier stringByAppendingString:@"-tex"];
        _pdfIdentifier = [self.identifier stringByAppendingString:@"-pdf"];
        self.lineBookmarks = [NSMutableSet new];
        self.selectedRange = NSMakeRange(0, 0);
        self.outlineElements = [NSMutableArray new];
        globalMessagesMap = [NSMutableDictionary new];
        __unsafe_unretained DocumentModel *weakSelf = self;
        if (!self.liveCompile) {
            [[NSUserDefaultsController sharedUserDefaultsController] addObserver:self forKeyPath:[@"values." stringByAppendingString:TMTDocumentEnableLiveCompile] options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:NULL];
            removeLiveCompileObserver = ^(void) {
                [[NSUserDefaultsController sharedUserDefaultsController] removeObserver:weakSelf forKeyPath:[@"values." stringByAppendingString:TMTDocumentEnableLiveCompile]];
            };
        }
        if (!self.openOnExport) {
            [[NSUserDefaultsController sharedUserDefaultsController] addObserver:self forKeyPath:[@"values." stringByAppendingString:TMTDocumentAutoOpenOnExport] options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:NULL];
            removeOpenOnExportObserver = ^(void) {
                [[NSUserDefaultsController sharedUserDefaultsController] removeObserver:weakSelf forKeyPath:[@"values." stringByAppendingString:TMTDocumentAutoOpenOnExport]];
            };
        }

        _filePresenter = [[GenericFilePresenter alloc] initWithOperationQueue:[NSOperationQueue currentQueue]];
        _filePresenter.observer =self;
        [self updateCompileSettingBindings:live];
        [self updateCompileSettingBindings:draft];
        [self updateCompileSettingBindings:final];
    }

- (void)initSingleDocumentDefaults {
    if (!self.project) {
        [self loadModelSpecificXAttributes];
    }
}

    - (void)initProjectSyncState
    {
        if (self.project) {
            ___projectSyncState = [__DocumentModelProjectSyncState fullyUnsynced];

            if (!super.bibFiles) {
                DDLogDebug(@"%@: sync bibfiles", self);
                super.bibFiles = self.project.bibFiles;
                [self.project addObserver:self forKeyPath:@"bibFiles" options:NSKeyValueObservingOptionNew context:NULL];
                ___projectSyncState.bibFiles = YES;
            }
            if (!super.mainDocuments) {
                DDLogDebug(@"%@: sync mainDocuments", self);
                super.mainDocuments = self.project.mainDocuments;
                [self.project addObserver:self forKeyPath:@"mainDocuments" options:NSKeyValueObservingOptionNew context:NULL];
                ___projectSyncState.mainDocuments = YES;
            }

            if (!super.encoding) {
                DDLogDebug(@"%@: sync encoding", self);
                super.encoding = self.project.encoding;
                [self.project addObserver:self forKeyPath:@"encoding" options:NSKeyValueObservingOptionNew context:NULL];
                ___projectSyncState.encoding = YES;
            }

        } else {
            ___projectSyncState = nil;
        }

    }

    + (void)initialize
    {
        if ([self class] == [DocumentModel class]) {
            LOGGING_LOAD
            GENERATOR_TYPES_TO_USE = @[@(TMTLogFileParser), @(TMTLacheckParser), @(TMTChktexParser)];
        }
    }

#pragma mark - NSCoding Support

    - (void)encodeWithCoder:(NSCoder *)aCoder
    {

        if (![[NSFileManager defaultManager] fileExistsAtPath:self.texPath]) {
            return;
        }
        
        [super encodeWithCoder:aCoder andProjectSyncState:___projectSyncState];
        [aCoder encodeObject:self.lastCompile forKey:@"lastCompile"];
        [aCoder encodeConditionalObject:self.project forKey:@"project"];
        NSString *basePath = self.project ? self.project.path.stringByDeletingLastPathComponent : self.texPath.stringByDeletingLastPathComponent;
        if (basePath) {
            NSString *relativePdfPath = [self.pdfPath relativePathWithBase:basePath];
            NSString *relativeTexPath = [self.texPath relativePathWithBase:basePath];
            [aCoder encodeObject:relativePdfPath forKey:@"pdfPath"];
            [aCoder encodeObject:relativeTexPath forKey:@"texPath"];
        }
        [aCoder encodeObject:self.liveCompile forKey:@"liveCompile"];
        [aCoder encodeObject:self.openOnExport forKey:@"openOnExport"];
        [aCoder encodeObject:@(self.documentOpened) forKey:@"documentOpened"];
    }

    - (id)initWithCoder:(NSCoder *)aDecoder
    {
        self = [super initWithCoder:aDecoder];
        if (self) {
            self.documentOpened = [[aDecoder decodeObjectForKey:@"documentOpened"] boolValue];
            self.lastCompile = [aDecoder decodeObjectForKey:@"lastCompile"];
            self.project = [aDecoder decodeObjectForKey:@"project"];
            self.pdfPath = [aDecoder decodeObjectForKey:@"pdfPath"];
            self.texPath = [aDecoder decodeObjectForKey:@"texPath"];
            self.liveCompile = [aDecoder decodeObjectForKey:@"liveCompile"];
            self.openOnExport = [aDecoder decodeObjectForKey:@"openOnExport"];
            [self initDefaults];
        }
        return self;
    }


#pragma mark - Loading & Saving

    - (NSString *)loadContent:(NSError *__autoreleasing *)error
    {
        TMT_TRACE
        if (!self.systemPath) {
            if (!self.texPath) {
                return nil;
            }
            self.systemPath = self.texPath;
        }
        NSStringEncoding encoding = 0;
        NSString *content;
        if (self.encoding && [self.encoding unsignedLongValue] > 0) {
            content = [[NSString alloc] initWithContentsOfFile:self.systemPath encoding:self.encoding.unsignedLongValue error:error];
        }
        else {
            content = [[NSString alloc] initWithContentsOfFile:self.systemPath usedEncoding:&encoding error:error];
            if (encoding == 0 && error != NULL) {
                *error = [[NSError alloc] initWithDomain:NSURLErrorDomain code:NSFileReadUnknownStringEncodingError userInfo:@{NSLocalizedFailureReasonErrorKey : NSLocalizedString(@"Can't detect a good encoding for this file.", @"Can't detect a good encoding for this file."), NSLocalizedRecoverySuggestionErrorKey : NSLocalizedString(@"Please try to set the encoding by yourself.", @"Please try to set the encoding by yourself."), NSLocalizedDescriptionKey : NSLocalizedString(@"Can't choose a correct encoding for this file", @"Can't choose a correct encoding for this file"), NSStringEncodingErrorKey : @(encoding), NSFilePathErrorKey : self.systemPath, NSURLErrorFailingURLErrorKey : [NSURL fileURLWithPath:self.systemPath]}];
            }
            else {
                self.encoding = @(encoding);
            }
        }

        if (error && *error) {
            DDLogError(@"Error while loading content: %@", *error);
            return nil;
        }
        if (content == nil && error != NULL) {
            *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:-1 userInfo:@{@"message" : @"Can't read file"}];
        } else {
            [self loadTextSpecificXAttributes];
        }
        return content;
    }

    - (BOOL)saveContent:(NSString *)content error:(NSError *__autoreleasing *)error
    {
        TMT_TRACE
        if (!self.systemPath) {
            return NO;
        }
        if (!self.encoding || [self.encoding unsignedLongValue] == 0) {
            self.encoding = [NSNumber numberWithUnsignedLong:NSUTF8StringEncoding];
        }
        BOOL success = [content writeToURL:[NSURL fileURLWithPath:self.systemPath] atomically:YES encoding:[self.encoding unsignedLongValue] error:error];
        if (!success) {
            NSStringEncoding alternate = NSUTF8StringEncoding;
            NSError *error2 = nil;
            success = [content writeToURL:[NSURL fileURLWithPath:self.systemPath] atomically:YES encoding:alternate error:&error2];
            if (success) {
                self.encoding = @(alternate);
            }
            else {
                if (error2) {
                    DDLogError(@"Error while saving: %@", [error2 userInfo]);
                }
                else {
                    DDLogError(@"Error while saving (unknown)");
                }
                if (error != NULL) {
                    *error = [[NSError alloc] initWithDomain:NSURLErrorDomain code:NSFileReadUnknownStringEncodingError userInfo:@{NSLocalizedFailureReasonErrorKey : NSLocalizedString(@"Can't detect a good encoding for this file.", @"Can't detect a good encoding for this file."), NSLocalizedRecoverySuggestionErrorKey : NSLocalizedString(@"Please try to set the encoding by yourself.", @"Please try to set the encoding by yourself."), NSLocalizedDescriptionKey : NSLocalizedString(@"Can't choose a correct encoding for this file", @"Can't choose a correct encoding for this file"), NSStringEncodingErrorKey : @(alternate), NSFilePathErrorKey : self.systemPath, NSURLErrorFailingURLErrorKey : [NSURL fileURLWithPath:self.systemPath]}];
                }
            }
        }
        if (success) {
            [self saveTextSpecificXAttributes];
            [self saveModelSpecificXAttributes];
            [[NSNotificationCenter defaultCenter] postNotificationName:TMTDidSaveDocumentModelContent object:self];
        }
        return success;
    }

#pragma mark - XATTR handling

- (void)saveTextSpecificXAttributes {
    TMT_TRACE
    NSError *error = nil;
    NSString *path = self.texPath ? self.texPath : self.systemPath;
    if (!path) {
        return;
    }
    if (self.lineBookmarks && ![OTMXAttribute setAttributeAtPath:path name:TMT_XATTR_LineBookmarks value:[self.lineBookmarks stringSerialization] error:&error]) {
        DDLogError(@"Can't set xattr for line bookmarks: %@", error.userInfo);
        
    }
    error = nil;
    if (![OTMXAttribute setAttributeAtPath:path name:TMT_XATTR_TextSelectedRange value:NSStringFromRange(self.selectedRange) error:&error]) {
        DDLogError(@"Can't set xattr for selected ranges: %@", error.userInfo);
    }
}

- (void)loadTextSpecificXAttributes {
    TMT_TRACE
    NSString *path = self.texPath ? self.texPath : self.systemPath;
    NSString *lineData = [OTMXAttribute stringAttributeAtPath:path name:TMT_XATTR_LineBookmarks error:NULL];
    if (lineData) {
        self.lineBookmarks =  [NSSet setFromStringSerialization:lineData withObjectDeserializer:^id(NSString * string) {
            return @([string integerValue]);
        }];
    }
    
    NSString *selectedRangeData = [OTMXAttribute stringAttributeAtPath:path name:TMT_XATTR_TextSelectedRange error:NULL];
    if (selectedRangeData) {
        self.selectedRange = NSRangeFromString(selectedRangeData);
    }
}


- (void)loadModelSpecificXAttributes {
    TMT_TRACE
    if (!self.texPath) {
        return;
    }
    NSString *liveCompileData = [OTMXAttribute stringAttributeAtPath:self.texPath name:TMT_XATTR_LiveCompileEnabled error:nil];
    if (liveCompileData) {
        self.liveCompile = @([liveCompileData boolValue]);
    }
    NSString *liveCompilerJSON = [OTMXAttribute stringAttributeAtPath:self.texPath name:TMT_XATTR_LiveCompiler error:nil];
    if (liveCompilerJSON) {
        self.hasLiveCompiler = YES;
        self.liveCompiler = [CompileSetting fromJSONString:liveCompilerJSON];
    }
    NSString *draftCompilerJSON = [OTMXAttribute stringAttributeAtPath:self.texPath name:TMT_XATTR_DraftCompiler error:nil];
    if (draftCompilerJSON) {
        self.hasDraftCompiler = YES;
        self.draftCompiler = [CompileSetting fromJSONString:draftCompilerJSON];
    }
    NSString *finalCompilerJSON = [OTMXAttribute stringAttributeAtPath:self.texPath name:TMT_XATTR_FinalCompiler error:nil];
    if (finalCompilerJSON) {
        self.hasFinalCompiler = YES;
        self.finalCompiler = [CompileSetting fromJSONString:finalCompilerJSON];
    }
    
}

- (void)saveModelSpecificXAttributes {
    TMT_TRACE
    if (!self.texPath || self.project) {
        return;
    }
    [OTMXAttribute setAttributeAtPath:self.texPath name:TMT_XATTR_LiveCompileEnabled value:[NSString stringWithFormat:@"%@", self.liveCompile] error:nil];
    if (self.hasLiveCompiler) {
        [OTMXAttribute setAttributeAtPath:self.texPath name:TMT_XATTR_LiveCompiler value:self.liveCompiler.toJSONString error:nil];
    } else {
        [OTMXAttribute removeAttributeAtPath:self.texPath name:TMT_XATTR_LiveCompiler error:nil];
    }
    if (self.hasDraftCompiler) {
        [OTMXAttribute setAttributeAtPath:self.texPath name:TMT_XATTR_DraftCompiler value:self.draftCompiler.toJSONString error:nil];
    } else {
        [OTMXAttribute removeAttributeAtPath:self.texPath name:TMT_XATTR_DraftCompiler error:nil];
    }
    if (self.hasFinalCompiler) {
        [OTMXAttribute setAttributeAtPath:self.texPath name:TMT_XATTR_FinalCompiler value:self.finalCompiler.toJSONString error:nil];
    } else {
        [OTMXAttribute removeAttributeAtPath:self.texPath name:TMT_XATTR_FinalCompiler error:nil];
    }
}

- (void)removeInvalidMaindocuments {
    if (!___projectSyncState.mainDocuments && self.project) {
        NSArray *mainDocuments = self.mainDocuments;
        NSFileManager *fm = [NSFileManager defaultManager];
        for(DocumentModel *md in mainDocuments) {
            if (![fm fileExistsAtPath:md.texPath]) {
                [self removeMainDocument:md];
            }
        }
    }
}

#pragma mark -  Getter

    - (NSArray *)bibFiles
    {

        if (!super.bibFiles && self.texPath) {
            NSString *dirPath = [self.texPath stringByDeletingLastPathComponent];
            NSMutableArray *matches = [NSMutableArray new];
            NSFileManager *manager = [NSFileManager defaultManager];
            NSError *error;
            NSArray *contents = [manager contentsOfDirectoryAtPath:dirPath error:&error];
            if (error) {
                DDLogError(@"Error while searching bib files: %@", error.userInfo);
                return nil;
            }
            for (NSString *item in contents) {
                if ([item.pathExtension.lowercaseString isEqualToString:@"bib"]) {
                    BibFile *f = [BibFile new];
                    f.path = [item absolutePathWithBase:[self.texPath stringByDeletingLastPathComponent]];
                    [matches addObject:f];
                }
            }
            if (matches.count > 0) {
                self.bibFiles = matches;
            }
        }
        return super.bibFiles;
    }

    - (DocumentModel *)currentMainDocument
    {
        if (!_currentMainDocument) {
            return self.mainDocuments.firstObject;
        }
        return _currentMainDocument;
    }

    - (NSString *)header
    {
        NSError *error;
        NSString *content = [NSString stringWithContentsOfFile:self.texPath encoding:self.encoding.unsignedLongValue error:&error];

        if (!error) {
            NSScanner *scanner = [NSScanner scannerWithString:content];
            NSString *result;
            BOOL success = [scanner scanUpToString:@"\\begin{document}" intoString:&result];
            if (success && result) {
                return result;
            }
        }
        return nil;
    }

- (NSSet *)openDocuments {
    return [NSSet setWithObject:self];
}

    - (Compilable *)mainCompilable
    {
        return self.project ? self.project.mainCompilable : self;
    }

    - (NSArray *)mainDocuments
    {
        if ([super mainDocuments]) {
            return [super mainDocuments];
        }
        return @[self];
    }

    - (NSString *)name
    {
        return self.texName;
    }

    - (NSString *)path
    {
        return self.texPath;
    }

    - (NSString *)pdfName
    {
        if (self.pdfPath) {
            return [self.pdfPath lastPathComponent];
        }
        return nil;
    }

    - (NSString *)pdfPath
    {
        NSString *path = _pdfPath;

        if (path && path.length > 0) {
            return path;
        }
        if (self.texPath && self.texPath.length > 0) {
            path = [self.texPath stringByDeletingPathExtension];
            return [path stringByAppendingPathExtension:@"pdf"];
        }
        return path;
    }

    - (NSString *)texName
    {
        if (self.texPath) {
            return [self.texPath lastPathComponent];
        }
        return nil;
    }

    - (NSString *)type
    {
        return NSLocalizedString(@"Document", @"Document");
    }

- (NSString *)description {
    return self.texPath ? self.texPath : [super description];
}

#pragma mark - Setter

    - (void)setCurrentMainDocument:(DocumentModel *)currentMainDocument
    {
        if (_currentMainDocument) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:TMTMessagesDidChangeNotification object:_currentMainDocument];
        }
        [self willChangeValueForKey:@"currentMainDocument"];
        _currentMainDocument = currentMainDocument;
        [self didChangeValueForKey:@"currentMainDocument"];
        if (_currentMainDocument) {
            [self updateMessages:[_currentMainDocument mergedGlobalMessages]];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainDocumentsMessagesDidChange:) name:TMTMessagesDidChangeNotification object:_currentMainDocument];
        }
    }

    - (void)setLiveCompile:(NSNumber *)liveCompile
    {
        if (removeLiveCompileObserver) {
            removeLiveCompileObserver();
            removeLiveCompileObserver = nil;
        }
        _liveCompile = liveCompile;
    }

    - (void)setOpenOnExport:(NSNumber *)openOnExport
    {
        if (removeOpenOnExportObserver) {
            removeOpenOnExportObserver();
            removeOpenOnExportObserver = nil;
        }
        _openOnExport = openOnExport;
    }

    - (void)setOutlineElements:(NSArray *)outlineElements
    {
        _outlineElements = [outlineElements copy];
        if (_outlineElements) {
            [[NSNotificationCenter defaultCenter] postNotificationName:TMTOutlineDidChangeNotification object:self userInfo:@{TMTOutlineChangePath : [NSMutableArray arrayWithObject:self]}];
        }
    }


    - (void)setTexPath:(NSString *)texPath
    {
        if (![_texPath isEqualToString:texPath]) {
            _texPath = texPath;
            if ([_texPath isAbsolutePath]) {
                [_filePresenter performSelectorInBackground:@selector(setPath:) withObject:texPath];
                [self initSingleDocumentDefaults];
                [self performSelectorInBackground:@selector(buildOutline) withObject:nil];
            }
        }
    }

    - (void)setBibFiles:(NSArray *)bibFiles
    {
        if (___projectSyncState.bibFiles) {
            [self.project removeObserver:self forKeyPath:@"bibFiles"];
            ___projectSyncState.bibFiles = NO;
        }
        super.bibFiles = bibFiles;
    }

    - (void)setMainDocuments:(NSArray *)mainDocuments
    {
        if (___projectSyncState.mainDocuments) {
            [self.project removeObserver:self forKeyPath:@"mainDocuments"];
            ___projectSyncState.mainDocuments = NO;
        }
        super.mainDocuments = mainDocuments;
        if (![super.mainDocuments containsObject:self.currentMainDocument]) {
            self.currentMainDocument = super.mainDocuments.firstObject;
        }
    }

    - (void)setEncoding:(NSNumber *)encoding
    {
        if (___projectSyncState.encoding) {
            [self.project removeObserver:self forKeyPath:@"encoding"];
            ___projectSyncState.encoding = NO;
        }
        super.encoding = encoding;
    }

    - (void)setProject:(ProjectModel *)project
    {
        if (project != _project) {
            _project = project;
            [self initProjectSyncState];
        }
    }

#pragma mark - Collection Helpers

    - (DocumentModel *)modelForTexPath:(NSString *)path byCreating:(BOOL)shouldCreate
    {
        if ([self.texPath isEqualToString:path]) {
            return self;
        }
        else if (self.project) {
            return [self.project modelForTexPath:path byCreating:shouldCreate];
        }
        else if (shouldCreate) {
            if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
                return nil;
            }
            DocumentModel *model = [DocumentModel new];
            model.texPath = path;
            return model;
        }
        return nil;
    }

- (void)deleteDocumentModel:(DocumentModel *)model {
    if (model == self) {
        return;
    }
    if (model == nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TMTDocumentModelIsDeleted object:nil userInfo:@{TMTTexIdentifierKey: self.texIdentifier, TMTPdfIdentifierKey : self.pdfIdentifier}];
        if (self.project) {
            
            [self.project deleteDocumentModel:self];
        }
    }
    
    if ((!___projectSyncState || !___projectSyncState.mainDocuments )&& [[super mainDocuments] containsObject:model]) {
        NSMutableArray *tmp = [[super mainDocuments] mutableCopy];
        [tmp removeObject:model];
        self.mainDocuments = tmp;
    }
}


# pragma mark - Key Value Observing

    - (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
    {
        // Pass notifications if change affects this model:
        if ([object isEqualTo:self.project]) {
            if ([keyPath isEqualToString:@"bibFiles"]) {
                super.bibFiles = self.project.bibFiles;
            } else if ([keyPath isEqualToString:@"mainDocuments"]) {
                super.mainDocuments = self.project.mainDocuments;
            } else if ([keyPath isEqualToString:@"encoding"]) {
                super.encoding = self.project.encoding;
            }
        } else if ([object isEqualTo:[NSUserDefaultsController sharedUserDefaultsController]]) {
            if ([keyPath isEqualToString:[@"values." stringByAppendingString:TMTDocumentEnableLiveCompile]]) {
                self.liveCompile = [[NSUserDefaultsController sharedUserDefaultsController] valueForKeyPath:[@"values." stringByAppendingString:TMTDocumentEnableLiveCompile]];
            } else if ([keyPath isEqualToString:[@"values." stringByAppendingString:TMTDocumentAutoOpenOnExport]]) {
                self.openOnExport = [[NSUserDefaultsController sharedUserDefaultsController] valueForKeyPath:[@"values." stringByAppendingString:TMTDocumentAutoOpenOnExport]];
            }
        } else {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }

    + (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
    {
        NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

        if ([key isEqualToString:@"pdfName"]) {
            keyPaths = [keyPaths setByAddingObject:@"pdfPath"];
        }
        else if ([key isEqualToString:@"texName"]) {
            keyPaths = [keyPaths setByAddingObject:@"texPath"];
        }
        else if ([key isEqualToString:@"path"]) {
            keyPaths = [keyPaths setByAddingObject:@"texPath"];
        }
        else if ([key isEqualToString:@"name"]) {
            keyPaths = [keyPaths setByAddingObject:@"texName"];
        }
        else if ([key isEqualToString:@"pdfPath"]) {
            keyPaths = [keyPaths setByAddingObject:@"texPath"];
        }
        return keyPaths;
    }

    + (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
    {
        if ([key isEqualToString:@"texName"]) {
            return YES;
        }
        if ([key isEqualToString:@"pdfName"]) {
            return YES;
        }
        return [super automaticallyNotifiesObserversForKey:key];
    }

# pragma mark - Compile Setting Handling

    - (void)updateCompileSettingBindings:(CompileMode)mode
    {
        switch (mode) {
            case live :
                if (!self.hasLiveCompiler) {
                    if (self.project) {
                        self.liveCompiler = [self.project.liveCompiler copy];
                        [self.liveCompiler bindAllTo:self.project.liveCompiler];
                    }
                }
                break;
            case draft :
                if (!self.hasDraftCompiler) {
                    if (self.project) {
                        self.draftCompiler = [self.project.draftCompiler copy];
                        [self.draftCompiler bindAllTo:self.project.draftCompiler];
                    }
                }
                break;
            case final :
                if (!self.hasFinalCompiler) {
                    if (self.project) {
                        self.finalCompiler = [self.project.finalCompiler copy];
                        [self.finalCompiler bindAllTo:self.project.finalCompiler];
                    }
                }
                break;
            default :
                break;
        }
        if (!self.project) {
            [super updateCompileSettingBindings:mode];
        }
    }

#pragma mark - Outline Handling

    - (void)buildOutline
    {
        NSString *content = [self loadContent:NULL];

        if (content) {
            [[OutlineExtractor new] extractIn:content forModel:self withCallback:nil];
        }
    }



#pragma mark - Message Handling

    - (void)updateMessages:(NSArray *)messages forType:(TMTMessageGeneratorType)type
    {
        @synchronized(self) {
        if (messages.count > 0) {
            globalMessagesMap[@(type)] = messages;
        }
        else if (globalMessagesMap[@(type)]) {
            [globalMessagesMap removeObjectForKey:@(type)];
        }
             [[NSNotificationCenter defaultCenter] postNotificationName:TMTMessagesDidChangeNotification object:self userInfo:@{TMTMessageCollectionKey : self.mergedGlobalMessages.copy}];
        }
    }

    - (NSArray *)mergedGlobalMessages
    {
        @synchronized(self) {
            NSMutableArray *result = [NSMutableArray new];
            
            for (NSNumber *type in GENERATOR_TYPES_TO_USE) {
                if (globalMessagesMap[type]) {
                    [result addObjectsFromArray:globalMessagesMap[type]];
                }
            }
            [result sortUsingSelector:@selector(compare:)];
            return result;
        }
    }

    - (void)mainDocumentsMessagesDidChange:(NSNotification *)note
    {
        [self updateMessages:note.userInfo[TMTMessageCollectionKey]];
    }

    - (void)updateMessages:(NSArray *)messages
    {
        NSMutableArray *tmp = [NSMutableArray new];

        for (TrackingMessage *m in messages) {
            if ([m.document isEqualToString:self.texPath]) {
                [tmp addObject:m];
            }
        }
        self.messages = tmp;
    }

#pragma mark - File Observer

    - (void)presentedItemDidMoveToURL:(NSURL *)newURL {
        NSError *error;
        NSURL *trashURL = [[NSFileManager defaultManager] URLForDirectory:NSTrashDirectory inDomain:NSUserDomainMask appropriateForURL:nil
                            create:NO error:&error];
        
        if (!trashURL && error) {
            DDLogError(@"Can't find trash url: %@", error);
        } else {
            if ([newURL.path hasPrefix:trashURL.path]) {
                if (self.project) {
                    [self deleteDocumentModel:nil];
                }
            } else {
                NSString *oldPDFPath = self.pdfPath;
                NSString *oldTexPath = self.texPath;
                self.texPath = newURL.path;
                self.systemPath = newURL.path;
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:oldPDFPath]) {
                    return;
                }
                NSString *relativePDFPath = [oldPDFPath relativePathWithBase:[oldTexPath stringByDeletingLastPathComponent]];
                self.pdfPath = [relativePDFPath absolutePathWithBase:[self.texPath stringByDeletingLastPathComponent]];
            }
        }
        
        
    }

@end


