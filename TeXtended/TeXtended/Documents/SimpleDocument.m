//
//  SimpleDocument.m
//  TeXtended
//
//  Created by Tobias Mende on 17.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "SimpleDocument.h"
#import "DocumentModel.h"
#import "HighlightingTextView.h"
#import "FileViewController.h"
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
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"SimpleDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
    
    /* initialize and set the linenumber view */
    lineNumberView = [[LineNumberView alloc] initWithScrollView:[self editorScrollView]];
    [self.editorScrollView setVerticalRulerView:lineNumberView];
    [self.editorScrollView setHasHorizontalRuler:NO];
    [self.editorScrollView setHasVerticalRuler:YES];
    [self.editorScrollView setRulersVisible:YES];
    _fileViewController = [[FileViewController alloc] init];
    [self.leftSidebar setSubviews:[NSArray arrayWithObjects:self.fileViewController.view, nil]];
    if(temporaryTextStorage) {
        [self.editorView setString:temporaryTextStorage];
        if (self.model.texPath) {
            [self.fileViewController loadPath:[[NSURL fileURLWithPath:self.model.texPath] URLByDeletingLastPathComponent]];
        }
    }
    
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (BOOL)saveToURL:(NSURL *)url ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation error:(NSError *__autoreleasing *)outError {
    BOOL success = [super saveToURL:url ofType:typeName forSaveOperation:saveOperation error:outError];
    if (saveOperation != NSAutosaveInPlaceOperation && saveOperation != NSAutosaveElsewhereOperation) {
        [self.editorView breakUndoCoalescing];
    }
    return success;
}

- (BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    if (![standardDocumentTypes containsObject:typeName]) {
        *outError = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnsupportedURL userInfo:nil];
        NSLog(@"Can't handle type %@", typeName);
        return NO;
    } 
        self.model.texPath = [url path];
        BOOL success = [self.model saveContent:self.editorView.string error:outError];
        return success;
    
}
- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    if (![standardDocumentTypes containsObject:typeName]) {
        *outError = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnsupportedURL userInfo:nil];
        return NO;
    }
    if (!self.model) {
        _model = [[DocumentModel alloc] initWithContext:self.context];
    }
    self.model.texPath = [url path];
    if (self.fileViewController) {
        [self.fileViewController loadPath:[[NSURL fileURLWithPath:self.model.texPath] URLByDeletingLastPathComponent]];
    }
    temporaryTextStorage = [self.model loadContent];
    if (self.editorView && temporaryTextStorage) {
        self.editorView.string = temporaryTextStorage;
    }
    return temporaryTextStorage != nil;
}

@end
