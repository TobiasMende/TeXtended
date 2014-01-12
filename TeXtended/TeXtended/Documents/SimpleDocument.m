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
#import <TMTHelperCollection/TMTLog.h>
#import "DocumentCreationController.h"
#import "TMTNotificationCenter.h"
#import "ConsoleManager.h"
#import "HighlightingTextView.h"
#import "MergeWindowController.h"

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
    }
    return self;
}



- (void) saveEntireDocumentWithDelegate:(id)delegate andSelector:(SEL)action {
    [self saveToURL:[self fileURL] ofType:[self fileType] forSaveOperation:NSAutosaveInPlaceOperation delegate:delegate didSaveSelector:action contextInfo:NULL];
}

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

- (void)setModel:(DocumentModel *)model {
    if (model != _model) {
        if (self.model) {
            [[TMTNotificationCenter centerForCompilable:self.model] removeObserver:self];
        }
        _model = model;
        if (self.model) {
            [[TMTNotificationCenter centerForCompilable:self.model] addObserver:self selector:@selector(firstResponderDidChangeNotification:) name:TMTFirstResponderDelegateChangeNotification object:nil];
        }
    }
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
        self.model.encoding = @([contr.encController selection]);
        
    }
    [self.model loadContent:outError];
    if (*outError) {
        return NO;
    }
    
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

- (IBAction)exportSingleDocument:(id)sender {
    if (!mergeWindowController) {
        mergeWindowController = [[MergeWindowController alloc] init];
    }
    
    NSString* content = [mergeWindowController getMergedContentOfFile:self.model.texPath withBase:[self.model.texPath stringByDeletingLastPathComponent]];
    
    NSSavePanel* panel = [NSSavePanel new];
    [self prepareSavePanel:panel];
    panel.directoryURL = [NSURL URLWithString:[self.model.texPath stringByDeletingLastPathComponent]];
    panel.canCreateDirectories = NO;
    panel.allowedFileTypes = @[@"tex"];
    panel.nameFieldLabel = NSLocalizedString(@"File Name:", @"File Name");
    panel.title = NSLocalizedString(@"Export as single document", @"Export as single document");
    
    [panel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSString *path = panel.URL.path;
            NSFileManager *fm = [NSFileManager defaultManager];
            if (![fm fileExistsAtPath:path]) {
                NSError *error;
                [content writeToFile:path atomically:YES encoding:[@([self.encController selection]) longValue] error:&error];
                if (error) {
                    DDLogError(@"Can't create document at %@: %@",path, error.userInfo);
                }
            }
        }
    }];
}

- (void)dealloc {
    DDLogVerbose(@"dealloc");
    [[ConsoleManager sharedConsoleManager] removeConsoleForModel:self.model];
}

@end
