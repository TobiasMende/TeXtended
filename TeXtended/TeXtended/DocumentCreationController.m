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

@interface DocumentCreationController ()

- (void) showProjectCreationPanel;
- (void) initializeProject:(ProjectDocument*)project;
@end


@implementation DocumentCreationController


- (NSInteger)runModalOpenPanel:(NSOpenPanel *)openPanel forTypes:(NSArray *)types {
    [openPanel setCanChooseDirectories:YES];
    if (!self.encController) {
        self.encController = [[EncodingController alloc] init];
    }
    [openPanel setAccessoryView:[self.encController view]];
    return [super runModalOpenPanel:openPanel forTypes:types];
}


- (void) openDocumentWithContentsOfURL:(NSURL *)url display:(BOOL)displayDocument completionHandler:(void (^)(NSDocument *, BOOL, NSError *))completionHandler
{
    [super openDocumentWithContentsOfURL:url display:displayDocument completionHandler:completionHandler];
    SimpleDocument *currDoc = self.currentDocument;
    NSNumber *num = [self.encController.encodings objectAtIndex:[self.encController.popUp indexOfItem:self.encController.popUp.selectedItem]];
    currDoc.model.encoding = num;
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
    if (!createProjectPanel) {
        createProjectPanel = [NSOpenPanel openPanel];
    }
    createProjectPanel.canChooseFiles = NO;
    createProjectPanel.canChooseDirectories = YES;
    createProjectPanel.title = NSLocalizedString(@"Choose Project Folder", @"chooseProjectFolder");
    createProjectPanel.canCreateDirectories = YES;
    [createProjectPanel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSURL *directory = [createProjectPanel URL];
            NSString *name = [directory lastPathComponent];
            NSString *path = [directory.path stringByAppendingPathComponent:[name stringByAppendingPathExtension:@"textendedproj"]];
            ProjectDocument *doc = [[ProjectDocument alloc] init];
            doc.fileType = @"TeXtendedProjectFile";
            doc.fileURL = [NSURL fileURLWithPath:path];
            NSError *error;
            [doc configurePersistentStoreCoordinatorForURL:doc.fileURL ofType:doc.fileType modelConfiguration:nil storeOptions:nil error:&error];
            ProjectModel *model = [[ProjectModel alloc] initWithContext:doc.managedObjectContext];
            model.path = [doc.fileURL path];
            doc.projectModel = model;
            if (error) {
                NSLog(@"DocumentCreationController: %@", error.userInfo);
            }
            [self addDocument:doc];
            [self initializeProject:doc];
        }
    }];
}

- (void)initializeProject:(ProjectDocument *)project {
    if (!configurationPanel) {
        configurationPanel = [NSOpenPanel openPanel];
    }
    configurationPanel.directoryURL = [project.fileURL URLByDeletingLastPathComponent];
    configurationPanel.canChooseFiles = YES;
    configurationPanel.canChooseDirectories = NO;
    configurationPanel.title = NSLocalizedString(@"Choose main files", @"chooseMainFiles");
    configurationPanel.allowsMultipleSelection = YES;
    configurationPanel.allowedFileTypes = [NSArray arrayWithObject:@"tex"];
    [configurationPanel beginWithCompletionHandler:^(NSInteger result) {
        NSLog(@"Test");
        if (result == NSFileHandlingPanelOKButton) {
            for (NSURL *url in configurationPanel.URLs) {
                DocumentModel *model = [project.projectModel modelForTexPath:url.path];
                [project.projectModel addMainDocumentsObject:model];
            }
            
            [project makeWindowControllers];
            [project showWindows];
        }
    }];
}

@end
