//
//  ProjectDocument.m
//  TeXtended
//
//  Created by Tobias Mende on 17.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "ProjectDocument.h"
#import "MainWindowController.h"
#import "DocumentController.h"
#import "ProjectModel.h"
#import <TMTHelperCollection/TMTLog.h>
#import "TMTNotificationCenter.h"
#import "ConsoleManager.h"
#import "MergeWindowController.h"
#import "EncodingController.h"

@interface ProjectDocument ()
- (NSURL*)projectFileUrlFromDirectory:(NSURL*)directory;
@end

@implementation ProjectDocument

+ (BOOL)preservesVersions {
    return NO;
}

- (id)init
{
    self = [super init];
    if (self) {
            // Add your subclass-specific initialization here.
            self.model = [ProjectModel new];
    }
    return self;
}

- (void)saveEntireDocumentWithDelegate:(id)delegate andSelector:(SEL)action {
    [self saveToURL:[self fileURL] ofType:[self fileType] forSaveOperation:NSAutosaveInPlaceOperation delegate:delegate didSaveSelector:action contextInfo:NULL];
}

- (void)setModel:(ProjectModel *)model {
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


-(BOOL)respondsToSelector:(SEL)aSelector {
    if (aSelector == @selector(duplicateDocument:)) {
        return NO;
    } else {
        return [super respondsToSelector:aSelector];
    }
}

- (BOOL)writeToURL:(NSURL *)url ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation originalContentsURL:(NSURL *)absoluteOriginalContentsURL error:(NSError *__autoreleasing *)outError {
    if (saveOperation != NSAutosaveInPlaceOperation && saveOperation != NSAutosaveElsewhereOperation) {
        [self.documentControllers makeObjectsPerformSelector:@selector(breakUndoCoalescing)];
    }
    @try {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.model];
        [data writeToURL:url atomically:YES];
        for( DocumentController *dc in self.documentControllers) {
            NSError *error;
            [dc saveDocumentModel:&error];
            if (error) {
                DDLogError(@"Can't save texfile %@. Error: %@", dc.model.texPath, error.userInfo);
            }
        }
    }
    @catch (NSException *exception) {
        DDLogError(@"Can't write content: %@", exception.userInfo);
        return NO;
    }
    return YES;
}


- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError *__autoreleasing *)error {
    @try {
        id obj = [NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithContentsOfURL:absoluteURL]];
        if (obj) {
            self.model = (ProjectModel *)obj;
            DDLogVerbose(@"READ: %@", absoluteURL);
            [self.model finishInitWithPath:[absoluteURL path]];
        }
    }
    @catch (NSException *exception) {
        DDLogError(@"Can't read content: %@", exception.userInfo);
        return NO;
    }
    return YES;
}

- (NSURL *)projectFileUrlFromDirectory:(NSURL *)directory {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *lastComponent = [directory lastPathComponent];
    NSArray * dirContents =
    [fm contentsOfDirectoryAtURL:directory
      includingPropertiesForKeys:@[]
                         options:NSDirectoryEnumerationSkipsHiddenFiles
                           error:nil];
    NSPredicate * fltr = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"pathExtension='%@'", TMTProjectFileExtension]];
    NSArray * projectFiles = [dirContents filteredArrayUsingPredicate:fltr];
    if (projectFiles.count == 1) {
        return projectFiles[0];
    }else if(projectFiles.count > 1) {
        NSURL *defaultFileURL = [directory URLByAppendingPathComponent:[lastComponent stringByAppendingPathExtension:TMTProjectFileExtension]];
        for (NSURL *url in projectFiles) {
            if ([url.path isEqualToString:defaultFileURL.path]) {
                return url;
            }
        }
        return projectFiles[0];
    }
    return nil;
}

- (IBAction)exportSingleDocument:(id)sender {
    if (!mergeWindowController) {
        mergeWindowController = [[MergeWindowController alloc] init];
    }
    else {
        [mergeWindowController reset];
    }
    
    NSMutableArray *documentNames = [[NSMutableArray alloc] init];
    NSMutableArray *documentPaths = [[NSMutableArray alloc] init];
    for (DocumentController* dc in self.documentControllers) {
        if (dc.model.texName) {
            [documentNames addObject:dc.model.texName];
            [documentPaths addObject:dc.model.texPath];
        }
    }
    mergeWindowController.popUpElements = [NSArray arrayWithArray:documentNames];
    mergeWindowController.popUpPaths = [NSArray arrayWithArray:documentPaths];
    
    [NSApp beginSheet:[mergeWindowController window]
       modalForWindow: [self.mainWindowController window]
        modalDelegate: self
       didEndSelector: @selector(mergeSheetDidEnd:returnCode:contextInfo:)
          contextInfo: nil];
    [NSApp runModalForWindow:[self.mainWindowController window]];
}

- (void)mergeSheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    NSString* path = [mergeWindowController.popUpPaths objectAtIndex:mergeWindowController.documentName.indexOfSelectedItem];
    NSString* content;
    
    @try {
        content = [mergeWindowController getMergedContentOfFile:path withBase:[path stringByDeletingLastPathComponent]];
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
    
    NSSavePanel* panel = [NSSavePanel new];
    [self prepareSavePanel:panel];
    panel.directoryURL = [NSURL URLWithString:[self.model.path stringByDeletingLastPathComponent]];
    panel.canCreateDirectories = NO;
    panel.allowedFileTypes = @[@"tex"];
    panel.nameFieldLabel = NSLocalizedString(@"File Name:", @"File Name");
    panel.title = NSLocalizedString(@"Export as single document", @"Export as single document");
    
    [panel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSString *path = panel.URL.path;
            NSError *error;
            [content writeToFile:path atomically:YES encoding:[@([self.encController selection]) longValue] error:&error];
            if (error) {
                DDLogError(@"Can't create document at %@: %@",path, error.userInfo);
            }
        }
    }];
}

- (void)dealloc {
    DDLogVerbose(@"ProjectDocument dealloc");
    for(DocumentModel *m in self.model.documents) {
        [[ConsoleManager sharedConsoleManager] removeConsoleForModel:m];
    }
}

@end
