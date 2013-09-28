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

static NSArray *TMTEncodingsToCheck;


@interface DocumentModel ()
- (void) registerProjectObserver;
- (void) unregisterProjectObserver;
- (void) initDefaults;
- (void) clearInheretedCompilers;
- (void) setupInheritedCompilers;
- (void)internalSetPath:(NSString*)path forKey:(NSString*)key;
- (NSString *)internalPathForKey:(NSString*)key;
@end

@implementation DocumentModel

@dynamic lastChanged;
@dynamic lastCompile;
@dynamic pdfPath;
@dynamic texPath;
@dynamic systemPath;
@dynamic project;
@dynamic encoding;
@dynamic liveCompile;
@dynamic openOnExport;
@dynamic outlineElements;

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
    if (self.encoding && [self.encoding unsignedLongValue] > 0) {
        encoding = [self.encoding unsignedLongValue];
    }
    NSString *content = [[NSString alloc] initWithContentsOfFile:self.systemPath usedEncoding:&encoding error:&error];
    if (error) {
        // Fallback to encoding search:
        for (NSNumber *number in TMTEncodingsToCheck) {
            encoding = [number unsignedLongValue];
            error = nil;
            content = [[NSString alloc] initWithContentsOfFile:self.systemPath encoding:encoding error:&error];
            
            if (!error) {
                break;
            }
            
        }
        
    }
    
    if (error) {
        DDLogError(@"Error while loading content: %@", [error userInfo]);
    }{
        DDLogInfo(@"Detected encoding: %li", encoding);
        self.encoding = [NSNumber numberWithUnsignedLong:encoding];
    }
    if (content) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TMTDidLoadDocumentModelContent object:self];
    }
    
    return content;
}

- (DocumentModel *)modelForTexPath:(NSString *)path {
    if ([self.texPath isEqualToString:path]) {
        return self;
    } else if(self.project) {
        return [self.project modelForTexPath:path];
    } else {
        DocumentModel *model = [[DocumentModel alloc] initWithContext:self.managedObjectContext];
        model.texPath = path;
        return model;
    }
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
        [[NSNotificationCenter defaultCenter] postNotificationName:TMTDidSaveDocumentModelContent object:self];
    }
    return success;
}


- (id)initWithContext:(NSManagedObjectContext *)context {
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Document" inManagedObjectContext:context];
    self = [super initWithEntity:description insertIntoManagedObjectContext:context];
    if (self) {
        [self initDefaults];
        [self registerProjectObserver];
        
    
    }
    return self;
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
            self.liveCompiler = [self.project.liveCompiler copy:self.managedObjectContext];
            [self.liveCompiler binAllTo:self.project.liveCompiler];
        }
        if (!self.draftCompiler) {
            self.draftCompiler = [self.project.draftCompiler copy:self.managedObjectContext];
            [self.draftCompiler binAllTo:self.project.draftCompiler];
        }
        if (!self.finalCompiler) {
            self.finalCompiler = [self.project.finalCompiler copy:self.managedObjectContext];
            [self.finalCompiler binAllTo:self.project.finalCompiler];
        }
    } else {
        if (!self.liveCompiler) {
            self.liveCompiler = [CompileSetting defaultLiveCompileSettingIn:self.managedObjectContext];
        }
        if (!self.draftCompiler) {
            self.draftCompiler = [CompileSetting defaultDraftCompileSettingIn:self.managedObjectContext];
        }
        if (!self.finalCompiler) {
            self.finalCompiler = [CompileSetting defaultFinalCompileSettingIn:self.managedObjectContext];
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
    [self internalSetValue:liveCompile forKey:@"liveCompile"];
    
}

- (void)setOpenOnExport:(NSNumber *)openOnExport {
    if (removeOpenOnExportObserver) {
        removeOpenOnExportObserver();
        removeOpenOnExportObserver = nil;
    }
    [self internalSetValue:openOnExport forKey:@"openOnExport"];
}


- (void)registerProjectObserver {
    if (!self.project) {
        return;
    }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postChangeNotification) name:TMTDocumentModelDidChangeNotification object:self.project];
}

- (void)unregisterProjectObserver {
    if (!self.project) {
        return;
    }
        [[NSNotificationCenter defaultCenter] removeObserver:self name:TMTDocumentModelDidChangeNotification object:self.project];
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
    NSSet* md;
    if([self primitiveValueForKey:@"mainDocuments"]) {
        [self willAccessValueForKey:@"mainDocuments"];
        md = (NSSet*) [self primitiveValueForKey:@"mainDocuments"];
        if ([md count] ==  0) {
            md = nil;
        }
        [self didAccessValueForKey:@"mainDocuments"];
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
    if(![self primitiveValueForKey:@"mainDocuments"]) {
        [self setMainDocuments:self.mainDocuments];
    }
    NSSet * set = [NSSet setWithObject:value];
    [self willChangeValueForKey:@"mainDocuments" withSetMutation:NSKeyValueUnionSetMutation usingObjects:set];
    [self setPrimitiveValue:[self.mainDocuments setByAddingObjectsFromSet:set] forKey:@"mainDocuments"];
    [self didChangeValueForKey:@"mainDocuments" withSetMutation:NSKeyValueUnionSetMutation usingObjects:set];
}

- (void)addMainDocuments:(NSSet *)values {
    if(![self primitiveValueForKey:@"mainDocuments"]) {
        [self setMainDocuments:self.mainDocuments];
    }
    [self willChangeValueForKey:@"mainDocuments" withSetMutation:NSKeyValueUnionSetMutation usingObjects:values];
    [self setPrimitiveValue:[self.mainDocuments setByAddingObjectsFromSet:values] forKey:@"mainDocuments"];
    [self didChangeValueForKey:@"mainDocuments" withSetMutation:NSKeyValueUnionSetMutation usingObjects:values];
}

- (DocumentModel *)headerDocument {
    DocumentModel* m;
    if ([self primitiveValueForKey:@"headerDocument"]) {
        [self willAccessValueForKey:@"headerDocument"];
        m = [self primitiveValueForKey:@"headerDocument"];
        [self didAccessValueForKey:@"headerDocument"];
    }
    else if (self.project) {
        m = [self.project headerDocument];
    }
    if (!m) {
        m = self;
    }
    return m;
}

- (void)setProject:(ProjectModel *)project {
    [self clearInheretedCompilers];
    [self unregisterProjectObserver];
    [self internalSetValue:project forKey:@"project"];
    [self registerProjectObserver];
    [self setupInheritedCompilers];
}

-(void)setEncoding:(NSNumber *)encoding
{
    [self willChangeValueForKey:@"encoding"];
    DDLogInfo(@"Set Encoding: Old %ld - New %ld", (long)[self.encoding integerValue], (long)[encoding integerValue]);
    [self setPrimitiveValue:encoding forKey:@"encoding"];
    [self didChangeValueForKey:@"encoding"];
}

- (NSNumber *)encoding {
    [self willAccessValueForKey:@"encoding"];
    NSNumber *enc = [self primitiveValueForKey:@"encoding"];
    [self didAccessValueForKey:@"encoding"];
    DDLogInfo(@"Return encoding: %ld",(long)[enc integerValue]);
    return enc;
}



- (NSString *)pdfPath {
    NSString *path = [self internalPathForKey:@"pdfPath"];
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
        if (![self primitiveValueForKey:keyPath]) {
            [self didChangeValueForKey:keyPath];
        }
    }
    if ([object isEqualTo:[NSUserDefaultsController sharedUserDefaultsController]]) {
        if ([keyPath isEqualToString:[@"values." stringByAppendingString:TMTDocumentEnableLiveCompile]]) {
            [self internalSetValue:[[NSUserDefaultsController sharedUserDefaultsController] valueForKeyPath:[@"values." stringByAppendingString:TMTDocumentEnableLiveCompile]] forKey:@"liveCompile"];
            return;
        }
        if ([keyPath isEqualToString:[@"values." stringByAppendingString:TMTDocumentAutoOpenOnExport]]) {
            [self internalSetValue:[[NSUserDefaultsController sharedUserDefaultsController] valueForKeyPath:[@"values." stringByAppendingString:TMTDocumentAutoOpenOnExport]] forKey:@"openOnExport"];
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

- (void)setTexPath:(NSString *)texPath {
    NSString *old = self.texPath;
    if (![old isEqualToString:texPath]) {
        [self internalSetPath:texPath forKey:@"texPath"];
    }
}

- (NSString *)texPath {
    return [self internalPathForKey:@"texPath"];
}




- (NSString *)internalPathForKey:(NSString *)key {
    [self willAccessValueForKey:key];
    NSString *path = [self primitiveValueForKey:key];
    [self didAccessValueForKey:key];
    if (path && ![path isAbsolutePath] && self.project) {
        path = [path absolutePathWithBase:self.project.folderPath];
    }
    return path;
}

- (void)internalSetPath:(NSString *)path forKey:(NSString *)key {
    if (path && [path isAbsolutePath] && self.project) {
        path = [path relativePathWithBase:self.project.folderPath];
    }
    [self internalSetValue:path forKey:key];
}

- (void)setPdfPath:(NSString *)pdfPath {
    NSString *old = [self internalPathForKey:@"pdfPath"];
    if (![old isEqualToString:pdfPath]) {
        [self internalSetPath:pdfPath forKey:@"pdfPath"];
    }
}

- (void)willTurnIntoFault {
    DDLogInfo(@"will turn into fault");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self unbind:@"liveCompile"];
    [self unbind:@"openOnExport"];
    [self unregisterProjectObserver];
    [super willTurnIntoFault];
    
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
