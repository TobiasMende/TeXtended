//
//  DocumentController.m
//  TeXtended
//
//  Created by Tobias Mende on 17.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "DocumentCreationController.h"
#import "Constants.h"
#import "ProjectDocument.h"
#import "ProjectModel.h"
#import "EncodingController.h"
#import "SimpleDocument.h"
#import "ApplicationController.h"
#import <TMTHelperCollection/TMTLog.h>
#import "ProjectCreationWindowController.h"

LOGGING_DEFAULT_DYNAMIC

@interface DocumentCreationController ()

    - (void)showProjectCreationPanel;

    - (void)showSingleDocumentFor:(NSURL *)url withCompletionHandler:(void (^) (DocumentModel *))completionHandler;
@end


@implementation DocumentCreationController
+ (void)initialize {
    LOGGING_LOAD
}

    - (NSInteger)runModalOpenPanel:(NSOpenPanel *)openPanel forTypes:(NSArray *)types
    {
        [openPanel setCanChooseDirectories:YES];
        if (!self.encController) {
            self.encController = [[EncodingController alloc] init];
        }
        [openPanel setAccessoryView:[self.encController view]];
        [openPanel setDelegate:self.encController];
        return [super runModalOpenPanel:openPanel forTypes:types];
    }


    - (NSString *)typeForContentsOfURL:(NSURL *)url error:(NSError * __autoreleasing *)outError
    {
        NSString *type = [super typeForContentsOfURL:url error:outError];
        if (!type && CFURLHasDirectoryPath((__bridge CFURLRef) url)) {
            // If no type was found yet and the url is a path to a directory, its a project folder type
            type = TMT_FOLDER_DOCUMENT_TYPE;
        }
        return type;
    }

    - (void)newProject:(id)sender
    {
        [self showProjectCreationPanel];

    }

    - (void)showProjectCreationPanel
    {
        self.projectCreationWindowController = [ProjectCreationWindowController new];

        __unsafe_unretained DocumentCreationController *weakSelf = self;
        self.projectCreationWindowController.terminationHandler = ^(ProjectDocument *document, BOOL success)
        {
            if (success) {
                [document saveToURL:document.fileURL ofType:@"TeXtendedProjectFile" forSaveOperation:NSSaveOperation completionHandler:^(NSError *errorOrNil)
                {
                    if (errorOrNil) {
                        DDLogWarn(@"Error while saving: %@", errorOrNil.userInfo);
                    }
                }];
                [weakSelf addDocument:document];
                [document makeWindowControllers];
                [document showWindows];
            }
        };
        [self.projectCreationWindowController showWindow:self];
    }

- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem {
    NSMenuItem *parent = [(NSMenuItem *)anItem parentItem];
    if ([parent.submenu isEqual:[ApplicationController sharedApplicationController].fileMenu]) {
        [[ApplicationController sharedApplicationController] updateRecentDocuments];
    }
    return [super validateUserInterfaceItem:anItem];
}

# pragma mark - Searching and Showing TexDocuments

    - (void)showTexDocumentForPath:(NSString *)path andCompletionHandler:(void (^)(DocumentModel *))completionHandler
    {
        [self showTexDocumentForPath:path withReferenceModel:nil andCompletionHandler:completionHandler];
    }

    - (void)openDocumentForCompilable:(Compilable *)compilable display:(BOOL)displayDocument completionHandler:(void (^)(BOOL success, NSError *error))callbackHandler
    {
        if (!compilable.path) {
            NSBeep();
            if (callbackHandler) {
                callbackHandler(NO, nil);
            }
            return;
        }

        [self openDocumentWithContentsOfURL:[NSURL fileURLWithPath:compilable.path] display:NO completionHandler:^(NSDocument *doc, BOOL documentWasAlreadyOpen, NSError *error) {
            if (error && callbackHandler) {
                callbackHandler(NO, error);
                return;
            }
            if ([doc isKindOfClass:[SimpleDocument class]]) {
                [(SimpleDocument *) doc setModel:(DocumentModel *) compilable];
            } else if ([doc isKindOfClass:[ProjectDocument class]]) {
                [(ProjectDocument *) doc setModel:(ProjectModel *) compilable];
            }
            [doc makeWindowControllers];
            
            [doc showWindows];
            
            if (callbackHandler) {
                callbackHandler(YES, error);
            }
        }];
        
}

    - (void)showTexDocumentForPath:(NSString *)path withReferenceModel:(Compilable *)model andCompletionHandler:(void (^)(DocumentModel *))completionHandler
    {
        NSString *searchPath = [path stringByStandardizingPath];
        NSURL *searchURL = [NSURL fileURLWithPath:searchPath];
        if (!model) {
            MainDocument *doc = [self documentForURL:searchURL];
            if (doc && [doc.model isKindOfClass:[DocumentModel class]]) {
                [doc openNewTabForCompilable:(DocumentModel *) doc.model];
                if (completionHandler) {
                    completionHandler((DocumentModel *) doc.model);
                }
            } else {
                [self showSingleDocumentFor:searchURL withCompletionHandler:completionHandler];
            }
        } else if (model.project) {
            MainDocument *doc = [self documentForURL:[NSURL fileURLWithPath:model.project.path]];
            DocumentModel *searchModel = [model modelForTexPath:searchPath byCreating:NO];
            if (!searchModel) {
                if ([searchPath hasPrefix:[model.project.path stringByDeletingLastPathComponent]]) {
                    // Path is in Project Directory
                    searchModel = [model modelForTexPath:searchPath byCreating:YES];
                } else {
                    // Path is elsewhere
                    [self showSingleDocumentFor:searchURL withCompletionHandler:completionHandler];
                    return;
                }

            }
            [doc openNewTabForCompilable:searchModel];
            if (completionHandler) {
                completionHandler(searchModel);
            }
        } else if ([model.path isEqualToString:searchPath]) {
            // Same single document
            MainDocument *doc = [self documentForURL:searchURL];
            [doc openNewTabForCompilable:(DocumentModel *) model];
            if (completionHandler) {
                completionHandler((DocumentModel *) model);
            }
        } else {
            // Different single document
            [self showSingleDocumentFor:searchURL withCompletionHandler:completionHandler];
        }
    }

    - (void)showSingleDocumentFor:(NSURL *)url withCompletionHandler:(void (^)(DocumentModel *))completionHandler
    {
        [self openDocumentWithContentsOfURL:url display:YES completionHandler:^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error)
        {
            if (!completionHandler) {
                return;
            }
            if (!error && [document isKindOfClass:[SimpleDocument class]]) {
                completionHandler((DocumentModel *) ((MainDocument *) document).model);
            } else {
                completionHandler(nil);
            }
        }];
    }


#pragma mark - Recent Documents

- (NSArray *) recentSimpleDocumentsURLs {
    NSArray *recentDocuments = [self recentDocumentURLs];
    NSIndexSet *recentTexDocuments = [recentDocuments indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        NSURL *url = (NSURL *)obj;
        NSString *type = [[DocumentCreationController sharedDocumentController] typeForContentsOfURL:url error:nil];
        if (type && [[DocumentCreationController sharedDocumentController] documentClassForType:type] == [SimpleDocument class]) {
            return YES;
        }
        return NO;
    }];
    
    return [recentDocuments objectsAtIndexes:recentTexDocuments];
}

- (NSArray *)recentProjectDocumentsURLs {
    NSArray *recentDocuments = [self recentDocumentURLs];
    
    NSIndexSet *recentProjectDocuments = [recentDocuments indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        NSURL *url = (NSURL *)obj;
        NSString *type = [[DocumentCreationController sharedDocumentController] typeForContentsOfURL:url error:nil];
        if (type && [[DocumentCreationController sharedDocumentController] documentClassForType:type] == [ProjectDocument class]) {
            return YES;
        }
        return NO;
    }];
    return [recentDocuments objectsAtIndexes:recentProjectDocuments];
}

@end
