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

@interface DocumentModel ()
- (void) registerProjectObserver;
- (void) unregisterProjectObserver;
@end

@implementation DocumentModel

@dynamic lastChanged;
@dynamic lastCompile;
@dynamic pdfPath;
@dynamic texPath;
@dynamic project;
@dynamic encoding;
@dynamic subCompilabels;

- (NSString *)loadContent {
    self.lastChanged = [[NSDate alloc] init];
    NSError *error;
    NSString *content;
    if (!self.texPath) {
        return nil;
    }
    if (self.encoding) {
        content = [NSString stringWithContentsOfFile:self.texPath encoding:[self.encoding unsignedLongValue] error:&error];
    } else {
        NSStringEncoding encoding;
        content = [NSString stringWithContentsOfFile:self.texPath usedEncoding:&encoding error:&error];
        self.encoding = [NSNumber numberWithUnsignedLong:encoding];
    }
    if (error) {
        NSLog(@"Error while reading document: %@", error);
        return nil;
    }
    return content;
}

- (BOOL)saveContent:(NSString *)content error:(NSError *__autoreleasing *)error{
    self.lastChanged = [[NSDate alloc] init];
    if (!self.texPath) {
        return NO;
    }
    return [content writeToURL:[NSURL fileURLWithPath:self.texPath] atomically:YES encoding:[self.encoding unsignedLongValue] error:error];
}


- (id)initWithContext:(NSManagedObjectContext *)context {
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Document" inManagedObjectContext:context];
    self = [super initWithEntity:description insertIntoManagedObjectContext:context];
    if (self) {
        self.encoding = [NSNumber numberWithUnsignedLong:NSUTF8StringEncoding];
        [self registerProjectObserver];
        
    
    }
    return self;
}

- (void)registerProjectObserver {
    if (!self.project) {
        return;
    }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postChangeNotification) name:TMTDocumentModelDidChangeNotification object:self.project];
    [self.project addObserver:self forKeyPath:@"draftCompiler" options:NSKeyValueObservingOptionNew context:NULL];
    [self.project addObserver:self forKeyPath:@"finalCompiler" options:NSKeyValueObservingOptionNew context:NULL];
    [self.project addObserver:self forKeyPath:@"liveCompiler" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)unregisterProjectObserver {
    if (!self.project) {
        return;
    }
        [[NSNotificationCenter defaultCenter] removeObserver:self name:TMTDocumentModelDidChangeNotification object:self.project];
    [self.project removeObserver:self forKeyPath:@"draftCompiler"];
    [self.project removeObserver:self forKeyPath:@"finalCompiler"];
    [self.project removeObserver:self forKeyPath:@"liveCompiler"];
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
