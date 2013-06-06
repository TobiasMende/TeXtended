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
NSSet *standardDocumentTypes;
@implementation SimpleDocument

+ (void)initialize {
    standardDocumentTypes = [[NSSet alloc] initWithObjects:@"Latex Document", @"Latex Class Document", @"Latex Style Document", nil];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        _context = [[NSManagedObjectContext alloc] init];
        self.context.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[NSManagedObjectModel mergedModelFromBundles:nil]];
        _model = [[DocumentModel alloc] initWithContext:self.context];
        _documentController = [[DocumentController alloc] initWithDocument:self.model andMainDocument:self];
    }
    return self;
}


- (void)makeWindowControllers {
    _mainWindowController = [[MainWindowController alloc] init];
   
    [self addWindowController:self.mainWindowController];
    if (self.documentController) {
        [self.documentController setWindowController:self.mainWindowController];
    }
}



//- (BOOL)saveToURL:(NSURL *)url ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation error:(NSError *__autoreleasing *)outError {
//    NSLog(@"%@",[url path]);
//    if (saveOperation != NSAutosaveInPlaceOperation && saveOperation != NSAutosaveElsewhereOperation) {
//        [self.documentController breakUndoCoalescing];
//    } else {
//        
//    }
//    BOOL success = [super saveToURL:url ofType:typeName forSaveOperation:saveOperation error:outError];
//    NSLog(@"Success: %@", [NSNumber numberWithBool:success]);
//    return success;
//}

+ (BOOL)autosavesInPlace {
    return YES;
}


- (BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation originalContentsURL:(NSURL *)absoluteOriginalContentsURL error:(NSError *__autoreleasing *)outError {

    if (saveOperation != NSAutosaveInPlaceOperation && saveOperation != NSAutosaveElsewhereOperation) {
        [self.documentController breakUndoCoalescing];
    }
    if (![standardDocumentTypes containsObject:typeName]) {
        *outError = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnsupportedURL userInfo:nil];
        NSLog(@"Can't handle type %@", typeName);
        return NO;
    }
    self.model.systemPath = [url path];
    self.model.texPath = [[self fileURL] path];
    BOOL success = [self.documentController saveDocument:outError];
    return success;
}


- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    if (![standardDocumentTypes containsObject:typeName]) {
        *outError = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnsupportedURL userInfo:nil];
        return NO;
    }
    if (!self.model) {
        _model = [[DocumentModel alloc] initWithContext:self.context];
        //_documentController = [[DocumentController alloc] initWithDocument:self.model andMainDocument:self];
        if(self.mainWindowController) {
            [self.documentController setWindowController:self.mainWindowController];
        }
    }
    
    self.model.systemPath = [url path];
    self.model.texPath = [[self fileURL] path];
    [self.documentController loadContent];

    return YES;
}

- (void)dealloc {
    NSLog(@"SimpleDocument dealloc");
}

@end
