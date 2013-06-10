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

static NSArray *TMTProjectObserverKeys;

@interface DocumentModel ()
- (void) registerProjectObserver;
- (void) unregisterProjectObserver;
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

+ (void)initialize {
    TMTProjectObserverKeys = [NSArray arrayWithObjects:@"draftCompiler",@"finalCompiler", @"liveCompiler", @"mainDocuments", nil];
    
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
        [self registerProjectObserver];
        
    
    }
    return self;
}

- (void)registerProjectObserver {
    if (!self.project) {
        return;
    }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postChangeNotification) name:TMTDocumentModelDidChangeNotification object:self.project];
    for( NSString *key in TMTProjectObserverKeys) {
        [self.project addObserver:self forKeyPath:key options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:NULL];
    }
}

- (void)unregisterProjectObserver {
    if (!self.project) {
        return;
    }
        [[NSNotificationCenter defaultCenter] removeObserver:self name:TMTDocumentModelDidChangeNotification object:self.project];
    for( NSString *key in TMTProjectObserverKeys) {
        [self.project removeObserver:self forKeyPath:key];
    }
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

- (NSPipe *)outputPipe {
    return outputPipe;
}

- (NSPipe *)inputPipe {
    return inputPipe;
}

- (void)setOutputPipe:(NSPipe *)pipe {
    [self willChangeValueForKey:@"outputPipe"];
    outputPipe = pipe;
    [self didChangeValueForKey:@"outputPipe"];
}

- (void)setInputPipe:(NSPipe *)pipe {
    [self willChangeValueForKey:@"inputPipe"];
    inputPipe = pipe;
    [self didChangeValueForKey:@"inputPipe"];
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
    [self unregisterProjectObserver];
    [self willChangeValueForKey:@"project"];
    [self setPrimitiveValue:project forKey:@"project"];
    [self didChangeValueForKey:@"project"];
    [self registerProjectObserver];
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


- (CompileSetting *)draftCompiler {
    [self willAccessValueForKey:@"draftCompiler"];
    CompileSetting *setting = [self primitiveValueForKey:@"draftCompiler"];
    if (setting) {
        return setting;
    }
    if (self.project) {
        return [self.project draftCompiler];
    }
    [self didAccessValueForKey:@"draftCompiler"];
    return [CompileSetting defaultDraftCompileSettingIn:[self managedObjectContext]];
}

- (CompileSetting *)liveCompiler {
    [self willAccessValueForKey:@"liveCompiler"];
    CompileSetting *setting = [self primitiveValueForKey:@"liveCompiler"];
    if (setting) {
        return setting;
    }
    if (self.project) {
        return [self.project liveCompiler];
    }
    [self didAccessValueForKey:@"liveCompiler"];
    return [CompileSetting defaultLiveCompileSettingIn:[self managedObjectContext]];
}

- (CompileSetting *)finalCompiler {
    [self willAccessValueForKey:@"finalCompiler"];
    CompileSetting *setting = [self primitiveValueForKey:@"finalCompiler"];
    if (setting) {
        return setting;
    }
    if (self.project) {
        return [self.project finalCompiler];
    }
    [self didAccessValueForKey:@"finalCompiler"];
    return [CompileSetting defaultFinalCompileSettingIn:[self managedObjectContext]];
}

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
