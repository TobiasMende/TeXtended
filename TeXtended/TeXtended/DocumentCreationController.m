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
#import "DocumentModel.h"
#import "Compilable.h"
#import "EncodingController.h"
#import "SimpleDocument.h"
#import "MainDocument.h"
#import <TMTHelperCollection/TMTLog.h>
#import "ProjectCreationWindowController.h"

@interface DocumentCreationController ()

- (void) showProjectCreationPanel;
- (void) showSingleDocumentFor:(NSURL *)url withCompletionHandler:(void (^) (DocumentModel *))completionHandler;
@end


@implementation DocumentCreationController


- (NSInteger)runModalOpenPanel:(NSOpenPanel *)openPanel forTypes:(NSArray *)types {
    [openPanel setCanChooseDirectories:YES];
    if (!self.encController) {
        self.encController = [[EncodingController alloc] init];
    }
    [openPanel setAccessoryView:[self.encController view]];
    [openPanel setDelegate:self.encController];
    return [super runModalOpenPanel:openPanel forTypes:types];
}


- (NSString *)typeForContentsOfURL:(NSURL *)url error:(NSError *__autoreleasing *)outError {
    NSString *type = [super typeForContentsOfURL:url error:outError];
    if(!type && CFURLHasDirectoryPath((__bridge CFURLRef)url)) {
        // If no type was found yet and the url is a path to a directory, its a project folder type
        type = TMT_FOLDER_DOCUMENT_TYPE;
    }
    return type;
}

- (void)newProject:(id)sender {
    [self showProjectCreationPanel];
    
}

- (void)showProjectCreationPanel {
    if(!self.projectCreationWindowController) {
        self.projectCreationWindowController = [ProjectCreationWindowController new];
    }
    
    __unsafe_unretained DocumentCreationController *weakSelf = self;
    self.projectCreationWindowController.terminationHandler = ^(ProjectDocument *document, BOOL success) {
        if (success) {
            [document saveToURL:document.fileURL ofType:@"TeXtendedProjectFile" forSaveOperation:NSSaveOperation completionHandler:^(NSError *errorOrNil) {
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
    // TODO: initialize the project creation controller. 
}

# pragma mark - Searching and Showing TexDocuments

- (void)showTexDocumentForPath:(NSString *)path andCompletionHandler:(void (^)(DocumentModel *))completionHandler {
    [self showTexDocumentForPath:path withReferenceModel:nil andCompletionHandler:completionHandler];
}

- (BOOL)openDocumentForCompilable:(Compilable *)compilable display:(BOOL)displayDocument andError:(NSError **)error {
    if (!compilable.path) {
        NSBeep();
        return NO;
    }
    
    NSDocument *doc = [self openDocumentWithContentsOfURL:[NSURL fileURLWithPath:compilable.path] display:NO error:error];
    if (*error) {
        return NO;
    }
    if ([doc isKindOfClass:[SimpleDocument class]]) {
        [(SimpleDocument*)doc setModel:(DocumentModel*)compilable];
    } else if ([doc isKindOfClass:[ProjectDocument class]]) {
        [(ProjectDocument*)doc setModel:(ProjectModel*)compilable];
    }
    [doc makeWindowControllers];
    
    [doc showWindows];
    return YES; 
}

- (void)showTexDocumentForPath:(NSString *)path withReferenceModel:(Compilable *)model andCompletionHandler:(void (^)(DocumentModel *))completionHandler {
    NSString *searchPath = [path stringByStandardizingPath];
    NSURL *searchURL = [NSURL fileURLWithPath:searchPath];
    if (!model) {
        MainDocument *doc = [self documentForURL:searchURL];
        if (doc && [doc.model isKindOfClass:[DocumentModel class]]) {
            [doc openNewTabForCompilable:(DocumentModel*)doc.model];
            if (completionHandler) {
                completionHandler((DocumentModel*)doc.model);
            }
        } else {
            [self showSingleDocumentFor:searchURL withCompletionHandler:completionHandler];
        }
    } else if(model.project){
        MainDocument *doc = [self documentForURL:[NSURL fileURLWithPath:model.project.path]];
        DocumentModel *searchModel = [model modelForTexPath:searchPath byCreating:NO];
        if(!searchModel) {
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
    } else if([model.path isEqualToString:searchPath]) {
        // Same single document
        MainDocument *doc = [self documentForURL:searchURL];
        [doc openNewTabForCompilable:(DocumentModel*)model];
        if (completionHandler) {
            completionHandler((DocumentModel*)model);
        }
    } else {
        // Different single document
        [self showSingleDocumentFor:searchURL withCompletionHandler:completionHandler];
    }
}

- (void)showSingleDocumentFor:(NSURL *)url withCompletionHandler:(void (^)(DocumentModel *))completionHandler {
    [self openDocumentWithContentsOfURL:url display:YES completionHandler:^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error) {
        if (!completionHandler) {
            return;
        }
        if (!error && [document isKindOfClass:[SimpleDocument class]]) {
            completionHandler((DocumentModel*)((MainDocument*)document).model);
        } else {
            completionHandler(nil);
        }
    }];
}


@end
