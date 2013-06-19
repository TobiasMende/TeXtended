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

static NSArray *TMTEncodingsToCheck;


@interface DocumentModel ()
- (void) registerProjectObserver;
- (void) unregisterProjectObserver;
- (void) initDefaults;
- (void) clearInheretedCompilers;
- (void) setupInheritedCompilers;
@end

@implementation DocumentModel

@dynamic lastChanged;
@dynamic lastCompile;
@dynamic pdfPath;
@dynamic texPath;
@dynamic systemPath;
@dynamic project;
@dynamic encoding;
@dynamic subCompilabels;
@dynamic liveCompile;

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
        return nil;
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
        NSLog(@"Error: %@", [error userInfo]);
    }{
        NSLog(@"Detected encoding: %li", encoding);
        self.encoding = [NSNumber numberWithUnsignedLong:encoding];
    }
    return content;
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
            NSLog(@"Error while saving: %@", [error2 userInfo]);
        } else {
            self.encoding = [NSNumber numberWithUnsignedLong:alternate];
        }
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
    [self setupInheritedCompilers];
    if (!self.liveCompile) {
       [self setLiveCompile:[NSNumber numberWithBool:YES]];
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
    [self willChangeValueForKey:@"project"];
    [self setPrimitiveValue:project forKey:@"project"];
    [self didChangeValueForKey:@"project"];
    [self registerProjectObserver];
    [self setupInheritedCompilers];
}



//- (NSNumber *)encoding {
//    [self willAccessValueForKey:@"encoding"];
//    NSNumber *enc = [self primitiveValueForKey:@"encoding"];
//    
//    [self didAccessValueForKey:@"encoding"];
//    if (!enc) {
//        return [NSNumber numberWithUnsignedLong:NSASCIIStringEncoding];
//    }
//    if ([enc unsignedLongValue] == 0) {
//        return [NSNumber numberWithUnsignedLong:NSUTF8StringEncoding];
//    }
//    return enc;
//}



- (NSString *)pdfPath {
    [self willAccessValueForKey:@"pdfPath"];
    NSString *path = [self primitiveValueForKey:@"pdfPath"];
    [self didAccessValueForKey:@"pdfPath"];
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


- (void)willTurnIntoFault {
#ifdef DEBUG
    NSLog(@"DocumentModel will turn into fault");
#endif
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self unregisterProjectObserver];
    [super willTurnIntoFault];
    
}

@end
