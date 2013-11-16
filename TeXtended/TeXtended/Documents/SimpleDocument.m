//
//  SimpleDocument.m
//  TeXtended
//
//  Created by Tobias Mende on 17.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "SimpleDocument.h"
#import "DocumentModel.h"
#import "MainWindowController.h"
#import "DocumentController.h"
#import "EncodingController.h"
#import "TMTLog.h"
#import "DocumentCreationController.h"

static const NSSet *standardDocumentTypes;
static BOOL autosave;
static const NSSet *SELECTORS_HANDLED_BY_DC;

@implementation SimpleDocument

+ (void)initialize {
    if (self == [SimpleDocument class]) {
        standardDocumentTypes = [[NSSet alloc] initWithObjects:@"Latex Document", @"Latex Class Document", @"Latex Style Document", nil];
        autosave = YES;
        
        SELECTORS_HANDLED_BY_DC = [NSSet setWithObjects:NSStringFromSelector(@selector(printDocument:)), nil];
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        self.model = [DocumentModel new];
        self.encController = [EncodingController new];
    }
    return self;
}

- (void) saveEntireDocumentWithDelegate:(id)delegate andSelector:(SEL)action {
    [self saveToURL:[self fileURL] ofType:[self fileType] forSaveOperation:NSAutosaveInPlaceOperation delegate:delegate didSaveSelector:action contextInfo:NULL];
}



//- (BOOL)saveToURL:(NSURL *)url ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation error:(NSError *__autoreleasing *)outError {
//    DDLogInfo(@"%@",[url path]);
//    if (saveOperation != NSAutosaveInPlaceOperation && saveOperation != NSAutosaveElsewhereOperation) {
//        [self.documentController breakUndoCoalescing];
//    } else {
//
//    }
//    BOOL success = [super saveToURL:url ofType:typeName forSaveOperation:saveOperation error:outError];
//    DDLogInfo(@"Success: %@", [NSNumber numberWithBool:success]);
//    return success;
//}

- (void)saveToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation delegate:(id)delegate didSaveSelector:(SEL)didSaveSelector contextInfo:(void *)contextInfo {
    [super saveToURL:absoluteURL ofType:typeName forSaveOperation:saveOperation delegate:delegate didSaveSelector:didSaveSelector contextInfo:contextInfo];
    if (!self.model.texPath) {
        self.model.texPath = [absoluteURL path];
    }
    
    NSNumber* encoding = [[self.encController.popUp selectedItem] representedObject];
    // In case of compiling the .tex file, [[self.encController.popUp selectedItem] representedObject] is (null).
    if (encoding) {
        self.model.encoding = encoding;
    }
}
- (BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation originalContentsURL:(NSURL *)absoluteOriginalContentsURL error:(NSError *__autoreleasing *)outError {
    if (saveOperation != NSAutosaveInPlaceOperation && saveOperation != NSAutosaveElsewhereOperation) {
        [self.documentControllers makeObjectsPerformSelector:@selector(breakUndoCoalescing)];
    }
    if (![standardDocumentTypes containsObject:typeName]) {
        if(outError) {
            *outError = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnsupportedURL userInfo:nil];
        }
        return NO;
    }
    self.model.systemPath = [url path];
    if ([[self fileURL] path]) {
        self.model.texPath = [[self fileURL] path];
    }
    
    BOOL success = YES;
    for (DocumentController *dc in self.documentControllers) {
        success &= [dc saveDocumentModel:outError];
    }
    
    return success;
    
    
}


- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    if (![standardDocumentTypes containsObject:typeName]) {
        if (outError) {
            *outError = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnsupportedURL userInfo:nil];
        }
        return NO;
    }
    if (!self.model) {
        DDLogError(@"The document model should not be nil!");
    }
    
    self.model.systemPath = [url path];
    self.model.texPath = [[self fileURL] path];
    DocumentCreationController* contr = [DocumentCreationController sharedDocumentController];
    if (contr.encController.selectionDidChange) {
        self.model.encoding = [NSNumber numberWithUnsignedLong:[contr.encController selection]];
        
    }
    
    [self initializeDocumentControllers];
    return YES;
}

-(BOOL) prepareSavePanel:(NSSavePanel *)savePanel
{
    [savePanel setAccessoryView:[self.encController view]];
    if (!self.model.encoding || [self.model.encoding unsignedLongValue] == 0) {
        [self.encController.popUp selectItemAtIndex:[self.encController.encodings indexOfObject:self.model.encoding]];
    }
    else {
        [self.encController.popUp selectItemAtIndex:[self.encController.encodings indexOfObject:[NSNumber numberWithUnsignedLong:NSUTF8StringEncoding]]];
    }
    
    return YES;
}

- (void)dealloc {
    DDLogVerbose(@"dealloc");
}

@end
