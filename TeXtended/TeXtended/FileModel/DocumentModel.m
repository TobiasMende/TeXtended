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
#import "TMTLog.h"
#import "EncodingController.h"
#import "TMTNotificationCenter.h"
#import "ConsoleManager.h"

static NSArray *TMTEncodingsToCheck;


@interface DocumentModel ()
- (void) registerProjectObserver;
- (void) unregisterProjectObserver;
- (void) initDefaults;
- (void) clearInheretedCompilers;
- (void) setupInheritedCompilers;
@end

@implementation DocumentModel

+ (void)initialize {
    
    TMTEncodingsToCheck = [NSArray arrayWithObjects:[NSNumber numberWithUnsignedLong:NSUTF8StringEncoding],
                                                    [NSNumber numberWithUnsignedLong:NSMacOSRomanStringEncoding],
                                                    [NSNumber numberWithUnsignedLong:NSASCIIStringEncoding],
                                                    [NSNumber numberWithUnsignedLong:NSISOLatin2StringEncoding],
                           [NSNumber numberWithUnsignedLong:NSISOLatin1StringEncoding],
                           nil];
}


- (NSString *)loadContent {
    self.lastChanged = [[NSDate alloc] init];
    NSError *error;
    if (!self.systemPath) {
        if (!self.texPath) {
            return nil;
        }
        self.systemPath = self.texPath;
    }
    NSStringEncoding encoding;
    NSString *content;
    if (self.encoding && [self.encoding unsignedLongValue] > 0) {
        content = [[NSString alloc] initWithContentsOfFile:self.systemPath encoding:self.encoding.unsignedLongValue error:&error];
    } else {
        content = [[NSString alloc] initWithContentsOfFile:self.systemPath usedEncoding:&encoding error:&error];
        self.encoding = [NSNumber numberWithUnsignedLong:encoding];
        
    }
    /*if (error) {
        // Fallback to encoding search:
        for (NSNumber *number in TMTEncodingsToCheck) {
            encoding = [number unsignedLongValue];
            error = nil;
            content = [[NSString alloc] initWithContentsOfFile:self.systemPath encoding:encoding error:&error];
            
            if (!error) {
                break;
            }
            
        }
        
    }*/
    
    if (error) {
        DDLogError(@"Error while loading content: %@", [error userInfo]);
    }
    if (content) {
        [[TMTNotificationCenter centerForCompilable:self] postNotificationName:TMTDidLoadDocumentModelContent object:self];
    }
    
    return content;
}


- (DocumentModel *)modelForTexPath:(NSString *)path byCreating:(BOOL)shouldCreate {
    if ([self.texPath isEqualToString:path]) {
        return self;
    } else if(self.project) {
        return [self.project modelForTexPath:path];
    } else if(shouldCreate){
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
            self.encoding = [NSNumber numberWithUnsignedLong:alternate];
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
        [self registerProjectObserver];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.lastChanged = [aDecoder decodeObjectForKey:@"lastChanged"];
        self.lastCompile = [aDecoder decodeObjectForKey:@"lastCompile"];
        self.encoding = [aDecoder decodeObjectForKey:@"encoding"];
        self.project = [aDecoder decodeObjectForKey:@"project"];
        NSString *relativePdfPath = [aDecoder decodeObjectForKey:@"pdfPath"];
        NSString *relativeTexPath = [aDecoder decodeObjectForKey:@"texPath"];
        self.pdfPath = [relativePdfPath absolutePathWithBase:[self.project.path stringByDeletingLastPathComponent]];
        self.texPath = [relativeTexPath absolutePathWithBase:[self.project.path stringByDeletingLastPathComponent]];
        self.outlineElements = [aDecoder decodeObjectForKey:@"outlineElements"];
        self.liveCompile = [aDecoder decodeObjectForKey:@"liveCompile"];
        self.openOnExport = [aDecoder decodeObjectForKey:@"openOnExport"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.lastCompile forKey:@"lastCompile"];
    [aCoder encodeObject:self.lastChanged forKey:@"lastChanged"];
    [aCoder encodeObject:self.encoding forKey:@"encoding"];
    [aCoder encodeObject:self.project forKey:@"project"];
    NSString *relativePdfPath = [self.pdfPath relativePathWithBase:[self.project.path stringByDeletingLastPathComponent]];
    NSString *relativeTexPath = [self.texPath relativePathWithBase:[self.project.path stringByDeletingLastPathComponent]];
    [aCoder encodeObject:relativePdfPath forKey:@"pdfPath"];
    [aCoder encodeObject:relativeTexPath forKey:@"texPath"];
    [aCoder encodeObject:self.outlineElements forKey:@"outlineElements"];
    [aCoder encodeObject:self.liveCompile forKey:@"liveCompile"];
    [aCoder encodeObject:self.openOnExport forKey:@"openOnExport"];
    [super encodeWithCoder:aCoder];
}

- (void)initDefaults {
    __weak typeof(self) weakSelf = self;
    [self setupInheritedCompilers];
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
}

- (void)setupInheritedCompilers {
    if (self.project) {
        if (!self.liveCompiler) {
            self.liveCompiler = [self.project.liveCompiler copy];
            [self.liveCompiler binAllTo:self.project.liveCompiler];
        }
        if (!self.draftCompiler) {
            self.draftCompiler = [self.project.draftCompiler copy];
            [self.draftCompiler binAllTo:self.project.draftCompiler];
        }
        if (!self.finalCompiler) {
            self.finalCompiler = [self.project.finalCompiler copy];
            [self.finalCompiler binAllTo:self.project.finalCompiler];
        }
    } else {
        if (!self.liveCompiler) {
            self.liveCompiler = [CompileSetting defaultLiveCompileSetting];
        }
        if (!self.draftCompiler) {
            self.draftCompiler = [CompileSetting defaultDraftCompileSetting];
        }
        if (!self.finalCompiler) {
            self.finalCompiler = [CompileSetting defaultFinalCompileSetting];
        }
    }
}

- (void)clearInheretedCompilers {
    if ([self.liveCompiler containsSameValuesAs:self.project.liveCompiler]) {
        self.liveCompiler = nil;
    }
    if ([self.draftCompiler containsSameValuesAs:self.project.draftCompiler]) {
        self.draftCompiler = nil;
    }
    if ([self.finalCompiler containsSameValuesAs:self.project.finalCompiler]) {
        self.finalCompiler = nil;
    }
    
    
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


- (void)registerProjectObserver {
    if (!self.project) {
        return;
    }
        [[TMTNotificationCenter centerForCompilable:self] addObserver:self selector:@selector(postChangeNotification) name:TMTDocumentModelDidChangeNotification object:self.project];
}

- (void)unregisterProjectObserver {
    if (!self.project) {
        return;
    }
        [[TMTNotificationCenter centerForCompilable:self] removeObserver:self name:TMTDocumentModelDidChangeNotification object:self.project];
}


#pragma mark -
#pragma mark Getter & Setter

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

- (NSSet *)mainDocuments {
    NSSet* md = nil;
    if([super mainDocuments] && [[super mainDocuments]count] >0) {
            md = [super mainDocuments];
    }
    if(!md && self.project) {
        md = [self.project mainDocuments];
    }
    if(!md) {
        md = [NSSet setWithObject:self];
    }
    return md;
}

- (void)addMainDocumentsObject:(DocumentModel *)value {
    
    if(![super mainDocuments]) {
        self.mainDocuments = [NSSet new];
        if (self.project) {
            self.mainDocuments = [self.mainDocuments setByAddingObjectsFromSet:self.project.mainDocuments];
        }
    }
    self.mainDocuments = [self.mainDocuments setByAddingObject:value];
}

- (void)addMainDocuments:(NSSet *)values {
    if(![super mainDocuments]) {
        self.mainDocuments = [NSSet new];
        if (self.project) {
            self.mainDocuments = [self.mainDocuments setByAddingObjectsFromSet:self.project.mainDocuments];
        }
    }
    self.mainDocuments = [self.mainDocuments setByAddingObjectsFromSet:values];
}


- (void)setProject:(ProjectModel *)project {
    if (self == self.mainCompilable) {
        [TMTNotificationCenter removeCenterForCompilable:self];
    }
    [self clearInheretedCompilers];
    [self unregisterProjectObserver];
    _project = project;
    [self registerProjectObserver];
    [self setupInheritedCompilers];
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



#pragma mark -
#pragma mark KVO

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
    [[ConsoleManager sharedConsoleManager] removeConsoleForModel:self];
    [[TMTNotificationCenter centerForCompilable:self] removeObserver:self];
    [self unbind:@"liveCompile"];
    [self unbind:@"openOnExport"];
    [self unregisterProjectObserver];
}

#pragma mark -
#pragma mark Getter

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


#pragma mark -
#pragma mark DocumentModelExtension

- (void)initOutlineElements {
    NSString *content = [self loadContent];
}

@end
