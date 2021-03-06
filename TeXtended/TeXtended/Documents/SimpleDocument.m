//
//  SimpleDocument.m
//  TeXtended
//
//  Created by Tobias Mende on 17.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "SimpleDocument.h"
#import "MainWindowController.h"
#import "DocumentController.h"
#import "EncodingController.h"
#import <TMTHelperCollection/TMTHelperCollection.h>
#import "DocumentCreationController.h"
#import "ConsoleManager.h"
#import "MergeWindowController.h"
#import "Template.h"
#import "TemplateController.h"
#import "TextViewController.h"

LOGGING_DEFAULT_DYNAMIC

static const NSSet *standardDocumentTypes;

static BOOL autosave;

static const NSSet *SELECTORS_HANDLED_BY_DC;

@implementation SimpleDocument

    + (void)initialize
    {
        if (self == [SimpleDocument class]) {
            LOGGING_LOAD
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

    - (void)setModel:(DocumentModel *)model
    {
        TMT_TRACE
        if (_model) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:TMTFirstResponderDelegateChangeNotification object:_model];
        }
        _model = model;
        if (_model) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(firstResponderDidChangeNotification:) name:TMTFirstResponderDelegateChangeNotification object:_model];

        }
    }


    - (void)saveEntireDocumentWithDelegate:(id)delegate andSelector:(SEL)action
    {
        TMT_TRACE
        if (self.documentNeedsSaving) {
            [self autosaveDocumentWithDelegate:delegate didAutosaveSelector:action contextInfo:NULL];
        } else if(delegate && [delegate respondsToSelector:action]) {
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [delegate performSelector:action withObject:nil];
            #pragma clang diagnostic pop

        }
    }

- (void)saveDocument:(id)sender {
    if (self.documentNeedsSaving) {
        [super saveDocument:sender];
    }
}

    - (void)saveToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation delegate:(id)delegate didSaveSelector:(SEL)didSaveSelector contextInfo:(void *)contextInfo
    {
        TMT_TRACE
        [super saveToURL:absoluteURL ofType:typeName forSaveOperation:saveOperation delegate:delegate didSaveSelector:didSaveSelector contextInfo:contextInfo];

        NSNumber *encoding = [[self.encController.popUp selectedItem] representedObject];
        // In case of compiling the .tex file, [[self.encController.popUp selectedItem] representedObject] is (null).
        if (encoding) {
            self.model.encoding = encoding;
        }
    }

    - (BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation originalContentsURL:(NSURL *)absoluteOriginalContentsURL error:(NSError * __autoreleasing *)outError
    {
        TMT_TRACE
        if (saveOperation != NSAutosaveInPlaceOperation && saveOperation != NSAutosaveElsewhereOperation) {
            [self.documentControllers makeObjectsPerformSelector:@selector(breakUndoCoalescing)];
        }
        if (![standardDocumentTypes containsObject:typeName]) {
            if (outError) {
                *outError = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnsupportedURL userInfo:nil];
            }
            return NO;
        }
        
        
        switch (saveOperation) {
            case NSAutosaveElsewhereOperation:
                [self saveAllContent:NULL force:NO];
                return [[NSFileManager defaultManager] copyItemAtURL:absoluteOriginalContentsURL toURL:url error:outError];
            case NSSaveAsOperation:
                self.model.systemPath = url.path;
                return [self saveAllContent:outError force:YES];
            default:
                DDLogDebug(@"URL(%@), ORIGINAL(%@)", url, absoluteOriginalContentsURL);
                self.model.systemPath = [url path];
                if (absoluteOriginalContentsURL) {
                    self.model.texPath = absoluteOriginalContentsURL.path;
                }
                return [self saveAllContent:outError force:NO];
        }
}

- (BOOL)saveAllContent:(NSError * __autoreleasing *)outError force:(BOOL)force{
    BOOL success = YES;
    for (DocumentController *dc in self.documentControllers) {
        success &= [dc saveDocumentModel:outError force:force];
    }
    
    return success;
}

    - (void)saveAsTemplate:(id)sender
    {
        [super saveAsTemplate:sender];
        __unsafe_unretained SimpleDocument *weakSelf = self;
        self.templateController.saveHandler = ^(Template *template, BOOL success)
        {
            if (success) {
                template.compilable = weakSelf.model;
                NSError *error;
                [template save:&error];
                if (error) {
                    DDLogError(@"%@", error);
                    NSAlert *alert = [NSAlert alertWithError:error];
                    [alert runModal];
                    return;
                }

                DocumentController *dc = weakSelf.documentControllers.anyObject;
                [template setDocumentWithContent:dc.textViewController.content model:weakSelf.model andError:&error];
                if (error) {
                    DDLogError(@"%@", error);
                    NSAlert *alert = [NSAlert alertWithError:error];
                    [alert runModal];
                    return;
                }
            }
        };
        [self.templateController openSavePanelForWindow:self.mainWindowController.window];
    }


    - (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError * __autoreleasing *)outError
    {
        TMT_TRACE
        if (outError != NULL) {
            *outError = nil;
        }
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
        DocumentCreationController *contr = [DocumentCreationController sharedDocumentController];
        if (contr.encController.selectionDidChange) {
            self.model.encoding = @([contr.encController selection]);

        }
        if (outError == NULL || *outError == nil) {
            NSString *content = [self.model loadContent:outError];
            if (!content) {
                return NO;
            }
        }
        if (outError != NULL && *outError) {
            return NO;
        }

        return YES;
    }


    - (BOOL)prepareSavePanel:(NSSavePanel *)savePanel
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

    - (IBAction)exportSingleDocument:(id)sender
    {
        if (!mergeWindowController) {
            mergeWindowController = [[MergeWindowController alloc] init];
        }
        else {
            [mergeWindowController reset];
        }

        NSString *content;

        @try {
            content = [mergeWindowController getMergedContentOfFile:self.model.texPath withBase:[self.model.texPath stringByDeletingLastPathComponent]];
        }
        @catch (NSException *exception) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:[exception name]];
            [alert setInformativeText:[exception reason]];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert runModal];
            return;
        }
        @finally {

        }

        NSSavePanel *panel = [NSSavePanel new];
        [self prepareSavePanel:panel];
        panel.directoryURL = [NSURL URLWithString:[self.model.texPath stringByDeletingLastPathComponent]];
        panel.canCreateDirectories = NO;
        panel.allowedFileTypes = @[@"tex"];
        panel.nameFieldLabel = NSLocalizedString(@"File Name:", @"File Name");
        panel.title = NSLocalizedString(@"Export as single document", @"Export as single document");

        [panel beginWithCompletionHandler:^(NSInteger result)
        {
            if (result == NSFileHandlingPanelOKButton) {
                NSString *path = panel.URL.path;
                NSFileManager *fm = [NSFileManager defaultManager];
                if (![fm fileExistsAtPath:path]) {
                    NSError *error;
                    [content writeToFile:path atomically:YES encoding:[@([self.encController selection]) longValue] error:&error];
                    if (error) {
                        DDLogError(@"Can't create document at %@: %@", path, error.userInfo);
                    }
                }
            }
        }];
    }

    - (void)setFileURL:(NSURL *)url
    {
        TMT_TRACE
        [super setFileURL:url];
        self.model.texPath = url.path;
    }

    - (void)dealloc
    {
        DDLogDebug(@"dealloc [%@]", self.fileURL);
        [[ConsoleManager sharedConsoleManager] removeConsoleForModel:self.model];
    }

@end
