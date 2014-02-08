//
//  DocumentModel.m
//  TeXtended
//
//  Created by Tobias Mende on 01.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "DocumentModel.h"
#import "ProjectModel.h"
#import "Constants.h"
#import "CompileSetting.h"
#import "NSString+PathExtension.h"
#import <TMTHelperCollection/TMTLog.h>
#import "EncodingController.h"
#import "TMTNotificationCenter.h"
#import "ConsoleManager.h"
#import "BibFile.h"
#import "OutlineExtractor.h"
static NSArray *TMTEncodingsToCheck;


@interface DocumentModel ()
- (void) initDefaults;

@end

@implementation DocumentModel

+ (void)initialize {
    
    TMTEncodingsToCheck = @[[NSNumber numberWithUnsignedLong:NSUTF8StringEncoding],
                                                    [NSNumber numberWithUnsignedLong:NSMacOSRomanStringEncoding],
                                                    [NSNumber numberWithUnsignedLong:NSASCIIStringEncoding],
                                                    [NSNumber numberWithUnsignedLong:NSISOLatin2StringEncoding],
                           [NSNumber numberWithUnsignedLong:NSISOLatin1StringEncoding]];
}


- (NSString *)loadContent:(NSError*__autoreleasing*)error {
    self.lastChanged = [NSDate new];
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
    } else {
        content = [[NSString alloc] initWithContentsOfFile:self.systemPath usedEncoding:&encoding error:error];
        if (encoding == 0 && error != NULL) {
            *error = [[NSError alloc] initWithDomain:NSURLErrorDomain code:NSFileReadUnknownStringEncodingError userInfo:@{NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Can't detect a good encoding for this file.", @"Can't detect a good encoding for this file."),NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Please try to set the encoding by yourself.", @"Please try to set the encoding by yourself."),NSLocalizedDescriptionKey: NSLocalizedString(@"Can't choose a correct encoding for this file", @"Can't choose a correct encoding for this file"), NSStringEncodingErrorKey: @(encoding), NSFilePathErrorKey:self.systemPath, NSURLErrorFailingURLErrorKey: [NSURL fileURLWithPath:self.systemPath]}];
        } else {
            self.encoding = @(encoding);
        }
        
    }
    
    if (error) {
        DDLogError(@"Error while loading content: %@", *error);
    }
    if (content == nil && error != NULL) {
        *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:-1 userInfo:@{@"message": @"Can't read file"}];
    }
    return content;
}


- (NSString *)header {
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

- (DocumentModel *)modelForTexPath:(NSString *)path byCreating:(BOOL)shouldCreate {
    if ([self.texPath isEqualToString:path]) {
        return self;
    } else if(self.project) {
        return [self.project modelForTexPath:path];
    } else if(shouldCreate){
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            return nil;
        }
        DocumentModel *model = [DocumentModel new];
        model.texPath = path;
        return model;
    }
    return nil;
}


- (BOOL)saveContent:(NSString *)content error:(NSError *__autoreleasing *)error{
    self.lastChanged = [[NSDate alloc] init];
    if (!self.systemPath) {
        return NO;
    }
    if (!self.encoding || [self.encoding unsignedLongValue] == 0) {
        self.encoding = [NSNumber numberWithUnsignedLong:NSUTF8StringEncoding];
    }
    BOOL success = [content writeToURL:[NSURL fileURLWithPath:self.systemPath] atomically:YES encoding:[self.encoding unsignedLongValue] error:error];
    if (*error) {
        NSStringEncoding alternate = NSUTF8StringEncoding;
        NSError *error2;
        success = [content writeToURL:[NSURL fileURLWithPath:self.systemPath] atomically:YES encoding:alternate error:&error2];
        if (error2) {
            DDLogError(@"Error while saving: %@", [error2 userInfo]);
        } else {
            self.encoding = @(alternate);
        }
    }
    if (success) {
        [[TMTNotificationCenter centerForCompilable:self] postNotificationName:TMTDidSaveDocumentModelContent object:self];
    }
    return success;
}


- (id)init {
    
    self = [super init];
    if (self) {
        [self initDefaults];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.lastChanged = [aDecoder decodeObjectForKey:@"lastChanged"];
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

- (void)finishInitWithPath:(NSString *)absolutePath {
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

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.lastCompile forKey:@"lastCompile"];
    [aCoder encodeObject:self.lastChanged forKey:@"lastChanged"];
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
}

- (void)initDefaults {
    _texIdentifier = [self.identifier stringByAppendingString:@"-tex"];
    _pdfIdentifier = [self.identifier stringByAppendingString:@"-pdf"];
    self.outlineElements = [NSMutableArray new];
    __unsafe_unretained typeof(self) weakSelf = self;
    if (!self.liveCompile) {
        [[NSUserDefaultsController sharedUserDefaultsController] addObserver:self forKeyPath:[@"values." stringByAppendingString:TMTDocumentEnableLiveCompile] options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:NULL];
        removeLiveCompileObserver = ^(void) {
            [[NSUserDefaultsController sharedUserDefaultsController] removeObserver:weakSelf forKeyPath:[@"values." stringByAppendingString:TMTDocumentEnableLiveCompile]];
        };
    }
    if (!self.openOnExport) {
        [[NSUserDefaultsController sharedUserDefaultsController] addObserver:self forKeyPath:[@"values." stringByAppendingString:TMTDocumentAutoOpenOnExport] options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:NULL];
        removeOpenOnExportObserver = ^(void) {
            [[NSUserDefaultsController sharedUserDefaultsController] removeObserver:weakSelf forKeyPath:[@"values." stringByAppendingString:TMTDocumentAutoOpenOnExport]];
        };
    }
    
    [self updateCompileSettingBindings:live];
    [self updateCompileSettingBindings:draft];
    [self updateCompileSettingBindings:final];
}
- (void)setLiveCompile:(NSNumber *)liveCompile {
    if (removeLiveCompileObserver) {
        removeLiveCompileObserver();
        removeLiveCompileObserver = nil;
    }
    _liveCompile = liveCompile;
    
}

- (void)setOpenOnExport:(NSNumber *)openOnExport {
    if (removeOpenOnExportObserver) {
        removeOpenOnExportObserver();
        removeOpenOnExportObserver = nil;
    }
    _openOnExport = openOnExport;
}



#pragma mark -
#pragma mark Getter & Setter

- (void)setTexPath:(NSString *)texPath {
    if (_texPath != texPath) {
        _texPath = texPath;
        if ([_texPath isAbsolutePath]) {
            [self buildOutline];
        }
    }
}

- (NSString *)texName {
    if (self.texPath) {
        return [self.texPath lastPathComponent];
    }
    return nil;
}

- (NSString *)pdfName {
    if (self.pdfPath) {
        return [self.pdfPath lastPathComponent];
    }
    return nil;
}

- (NSPipe *)consoleOutputPipe {
    return consoleOutputPipe;
}

- (NSPipe *)consoleInputPipe {
    return consoleInputPipe;
}

- (void)setConsoleOutputPipe:(NSPipe *)pipe {
    [self willChangeValueForKey:@"consoleOutputPipe"];
    consoleOutputPipe = pipe;
    [self didChangeValueForKey:@"consoleOutputPipe"];
}

- (void)setConsoleInputPipe:(NSPipe *)pipe {
    [self willChangeValueForKey:@"consoleInputPipe"];
    consoleInputPipe = pipe;
    [self didChangeValueForKey:@"consoleInputPipe"];
}

- (Compilable *)mainCompilable {
    if (self.project) {
        return [self.project mainCompilable];
    }
    return [super mainCompilable];
}

- (NSArray *)mainDocuments {
    NSArray* md = nil;
    if([super mainDocuments] && [[super mainDocuments]count] >0) {
            md = [super mainDocuments];
    }
    if(!md && self.project) {
        md = [self.project mainDocuments];
    }
    if(!md) {
        md = @[self];
    }
    return md;
}

- (void)addMainDocumentsObject:(DocumentModel *)value {
    if ([self.mainDocuments containsObject:value]) {
        return;
    }
    if(![super mainDocuments]) {
        self.mainDocuments = [NSArray new];
        if (self.project) {
            self.mainDocuments = [self.mainDocuments arrayByAddingObjectsFromArray:self.project.mainDocuments];
        }
    }
    self.mainDocuments = [self.mainDocuments arrayByAddingObject:value];
}

- (void)addMainDocuments:(NSArray *)values {
    if(![super mainDocuments]) {
        self.mainDocuments = [NSArray new];
        if (self.project) {
            self.mainDocuments = [self.mainDocuments arrayByAddingObjectsFromArray:self.project.mainDocuments];
        }
    }
    self.mainDocuments = [self.mainDocuments arrayByAddingObjectsFromArray:values];
}


- (void)setProject:(ProjectModel *)project {
    if (self == self.mainCompilable) {
        [TMTNotificationCenter removeCenterForCompilable:self];
    }
    _project = project;
}




- (NSString *)pdfPath {
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


- (NSString *)infoTitle {
    return NSLocalizedString(@"Document Information", @"Documentinformation");
}

- (NSString *)type {
    return NSLocalizedString(@"Document", @"Document");
}

- (NSString *)name {
    return self.texName;
}

- (NSString *)path {
    return self.texPath;
}

- (NSArray *)bibFiles {
    if (self.project) {
        return self.project.bibFiles;
    } else if(!_bibFiles && self.texPath){
        NSString *dirPath = [self.texPath stringByDeletingLastPathComponent];
        NSMutableArray *matches = [NSMutableArray new];
        NSFileManager *manager = [NSFileManager defaultManager];
        NSError *error;
        NSArray *contents = [manager contentsOfDirectoryAtPath:dirPath error:&error];
        if (error) {
            DDLogError(@"Error while searching bib files: %@", error.userInfo);
            return nil;
        }
        for(NSString *item in contents) {
            if ([item.pathExtension.lowercaseString isEqualToString:@"bib"]) {
                BibFile *f = [BibFile new];
                f.path = [item absolutePathWithBase:[self.texPath stringByDeletingLastPathComponent]];
                [matches addObject:f];
            }
        }
        if (matches.count > 0) {
            _bibFiles = matches;
        }
    }
    return _bibFiles;
}

- (NSNumber *)encoding {
    if (!super.encoding && self.project) {
        return self.project.encoding;
    }
    return super.encoding;
}

- (void)setOutlineElements:(NSMutableArray *)outlineElements {
        _outlineElements = outlineElements;
        if (_outlineElements) {
            [[NSNotificationCenter defaultCenter] postNotificationName:TMTOutlineDidChangeNotification object:self userInfo:@{TMTOutlineChangePath: [NSMutableArray arrayWithObject:self]}];
        }
}



# pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    // Pass notifications if change affects this model:
    if ([object isEqualTo:self.project]) {
        if (![self valueForKeyPath:keyPath]) {
            [self didChangeValueForKey:keyPath];
        }
    }
    if ([object isEqualTo:[NSUserDefaultsController sharedUserDefaultsController]]) {
        if ([keyPath isEqualToString:[@"values." stringByAppendingString:TMTDocumentEnableLiveCompile]]) {
            self.liveCompile =[[NSUserDefaultsController sharedUserDefaultsController] valueForKeyPath:[@"values." stringByAppendingString:TMTDocumentEnableLiveCompile]];
            return;
        }
        if ([keyPath isEqualToString:[@"values." stringByAppendingString:TMTDocumentAutoOpenOnExport]]) {
            self.openOnExport = [[NSUserDefaultsController sharedUserDefaultsController] valueForKeyPath:[@"values." stringByAppendingString:TMTDocumentAutoOpenOnExport]];
            return;
        }
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}


+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    if ([key isEqualToString:@"pdfName"]) {
        keyPaths = [keyPaths setByAddingObject:@"pdfPath"];
    } else if([key isEqualToString:@"texName"]) {
        keyPaths = [keyPaths setByAddingObject:@"texPath"];
    } else if([key isEqualToString:@"path"]) {
        keyPaths = [keyPaths setByAddingObject:@"texPath"];
    } else if([key isEqualToString:@"name"]) {
        keyPaths = [keyPaths setByAddingObject:@"texName"];  
    } else if([key isEqualToString:@"pdfPath"]) {
        keyPaths = [keyPaths setByAddingObject:@"texPath"];
    }
    return keyPaths;
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    if ([key isEqualToString:@"texName"]) {
        return YES;
    }
    if ([key isEqualToString:@"pdfName"]) {
        return YES;
    }
    return [super automaticallyNotifiesObserversForKey:key];
}






- (void)dealloc {
    DDLogInfo(@"dealloc");
    [self unbind:@"liveCompile"];
    [self unbind:@"openOnExport"];
    if (!self.project) {
        [[TMTNotificationCenter centerForCompilable:self] removeObserver:self];
    }
}


# pragma mark - Compile Setting Handling

- (void)updateCompileSettingBindings:(CompileMode)mode {
    switch (mode) {
        case live:
            if (!self.hasLiveCompiler) {
                if (self.project) {
                    self.liveCompiler = [self.project.liveCompiler copy];
                    [self.liveCompiler bindAllTo:self.project.liveCompiler];
                }
            }
            break;
        case draft:
            if (!self.hasDraftCompiler) {
                if (self.project) {
                    self.draftCompiler = [self.project.draftCompiler copy];
                    [self.draftCompiler bindAllTo:self.project.draftCompiler];
                }
            }
            break;
        case final:
            if (!self.hasFinalCompiler) {
                if (self.project) {
                    self.finalCompiler = [self.project.finalCompiler copy];
                    [self.finalCompiler bindAllTo:self.project.finalCompiler];
                }
            }
            break;
        default:
            break;
    }
    if (!self.project) {
        [super updateCompileSettingBindings:mode];
    }
}


#pragma mark -
#pragma mark DocumentModelExtension

- (void)buildOutline {
    NSString *content = [self loadContent:NULL];
    if (content) {
        [[OutlineExtractor new] extractIn:content forModel:self withCallback:nil];
    }
}

@end
