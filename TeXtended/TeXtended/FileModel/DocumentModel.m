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
}


- (NSString *)texName {
    if (self.texPath) {
        return [self.texPath lastPathComponent];
    }
    return nil;
}

- (NSString *)loadContent {
    self.lastChanged = [[NSDate alloc] init];
    NSLog(@"Load");
    NSError *error, *error2;
    NSString *content;
    if (!self.systemPath) {
        return nil;
    }
    if (self.encoding && self.encoding.unsignedLongValue > 0) {
        content = [NSString stringWithContentsOfFile:self.systemPath encoding:[self.encoding unsignedLongValue] error:&error];
    }
    if (error || !self.encoding || self.encoding.unsignedLongValue == 0) {
        NSStringEncoding encoding = NSASCIIStringEncoding;
        content = [NSString stringWithContentsOfFile:self.systemPath usedEncoding:&encoding error:&error2];
        
        self.encoding = [NSNumber numberWithUnsignedLong:encoding];
    }
    if (error2) {
        NSLog(@"Error while reading document: %@", [error2 userInfo]);
    }
    return content;
}


- (BOOL)saveContent:(NSString *)content error:(NSError *__autoreleasing *)error{
    self.lastChanged = [[NSDate alloc] init];
    if (!self.systemPath) {
        return NO;
    }
    NSStringEncoding encoding = [self.encoding unsignedLongValue];
    if (!encoding) {
        self.encoding = [NSNumber numberWithUnsignedLong:NSUTF8StringEncoding];
    }
    return [content writeToURL:[NSURL fileURLWithPath:self.systemPath] atomically:YES encoding:[self.encoding unsignedLongValue] error:error];
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


- (void)prepareForDeletion {
    NSLog(@"prepare");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super prepareForDeletion];
}


#pragma mark -
#pragma mark Getter & Setter

- (NSPipe *)outputPipe {
    return outputPipe;
}

- (NSPipe *)inputPipe {
    return inputPipe;
}

- (void)setOutputPipe:(NSPipe *)pipe {
    outputPipe = pipe;
}

- (void)setInputPipe:(NSPipe *)pipe {
    inputPipe = pipe;
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
    [self didAccessValueForKey:@"draftCompiler"];
    if (setting) {
        return setting;
    }
    if (self.project) {
        return [self.project draftCompiler];
    }
    return [CompileSetting defaultDraftCompileSettingIn:[self managedObjectContext]];
}

- (CompileSetting *)liveCompiler {
    [self willAccessValueForKey:@"liveCompiler"];
    CompileSetting *setting = [self primitiveValueForKey:@"liveCompiler"];
    [self didAccessValueForKey:@"liveCompiler"];
    if (setting) {
        return setting;
    }
    if (self.project) {
        return [self.project liveCompiler];
    }
    return [CompileSetting defaultLiveCompileSettingIn:[self managedObjectContext]];
}

- (CompileSetting *)finalCompiler {
    [self willAccessValueForKey:@"finalCompiler"];
    CompileSetting *setting = [self primitiveValueForKey:@"finalCompiler"];
    [self didAccessValueForKey:@"finalCompiler"];
    if (setting) {
        return setting;
    }
    if (self.project) {
        return [self.project finalCompiler];
    }
    return [CompileSetting defaultFinalCompileSettingIn:[self managedObjectContext]];
}

- (NSString *)pdfPath {
    NSString *path = [self primitiveValueForKey:@"pdfPath"];
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


@end
