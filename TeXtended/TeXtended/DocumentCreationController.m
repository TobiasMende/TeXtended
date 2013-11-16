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
#import "EncodingController.h"
#import "SimpleDocument.h"
#import "TMTLog.h"
#import "ProjectCreationWindowController.h"

@interface DocumentCreationController ()

- (void) showProjectCreationPanel;
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
    
    __weak DocumentCreationController *weakSelf = self;
    self.projectCreationWindowController.terminationHandler = ^(ProjectDocument *document, BOOL success) {
        if (success) {
            [document setupPeristentStore];
            [document saveToURL:document.fileURL ofType:@"TeXtendedProjectFile" forSaveOperation:NSSaveOperation completionHandler:^(NSError *errorOrNil) {
                if (errorOrNil) {
                    DDLogWarn(@"Error while saving: %@", errorOrNil.userInfo);
                }
            }];
            [weakSelf addDocument:document];
            [document makeWindowControllers];
        }
    };
    [self.projectCreationWindowController showWindow:self];
    // TODO: initialize the project creation controller. 
}

@end
