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

@interface ProjectDocument ()
- (NSURL*)projectFileUrlFromDirectory:(NSURL*)directory;
@end

@implementation ProjectDocument

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
    NSPredicate * fltr = [NSPredicate predicateWithFormat:@"pathExtension='teXpf'"];
    NSArray * projectFiles = [dirContents filteredArrayUsingPredicate:fltr];
    if (projectFiles.count == 1) {
        return projectFiles[0];
    }else if(projectFiles.count > 1) {
        NSURL *defaultFileURL = [directory URLByAppendingPathComponent:[lastComponent stringByAppendingPathExtension:@"teXpf"]];
        for (NSURL *url in projectFiles) {
            if ([url.path isEqualToString:defaultFileURL.path]) {
                return url;
            }
        }
        return projectFiles[0];
    }
    return nil;
    
    
    
}


- (void)dealloc {
    DDLogVerbose(@"ProjectDocument dealloc");
    for(DocumentModel *m in self.model.documents) {
        [[ConsoleManager sharedConsoleManager] removeConsoleForModel:m];
    }
}

@end
