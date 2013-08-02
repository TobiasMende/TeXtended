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

@implementation ProjectDocument

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
    }
    return self;
}

- (void)makeWindowControllers {
    _mainWindowController = [[MainWindowController alloc] init];
    
    [self addWindowController:self.mainWindowController];
    if (!self.documentControllers || self.documentControllers.count == 0) {
        DocumentController *dc = [[DocumentController alloc] initWithDocument:[[self.projectModel.mainDocuments allObjects] objectAtIndex:0] andMainDocument:self];
        self.documentControllers = [NSMutableSet setWithObject:dc];
    }
    for (DocumentController* dc in self.documentControllers) {
        if ([[[self.projectModel.mainDocuments allObjects] objectAtIndex:0] isEqual:dc.model]) {
            [dc setWindowController:self.mainWindowController];
        }
    }
}

- (Compilable *)model {
    return self.projectModel;
}

- (void)saveEntireDocumentWithDelegate:(id)delegate andSelector:(SEL)action {
    //FIXME: implement this!
}

- (BOOL)writeToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation originalContentsURL:(NSURL *)absoluteOriginalContentsURL error:(NSError *__autoreleasing *)error {
    
    /* save all documents */
    for (DocumentController* dc in self.documentControllers) {
        [dc saveDocument:error];
    }
    
    return [super writeToURL:absoluteURL ofType:typeName forSaveOperation:saveOperation originalContentsURL:absoluteOriginalContentsURL error:error];
}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError *__autoreleasing *)error {
    NSURL *finalURL;
    if ([typeName isEqualToString:@"TeXtendedProjectFolder"]) {
        // Get Project URL and open it.
    } else if([typeName isEqualToString:@"TeXtendedProjectFile"]) {
        finalURL = absoluteURL;
    }
    NSLog(@"Project(%@): %@", typeName, absoluteURL);
    
    if (!finalURL) {
        // Abort reading if no matching project was found
        return NO;
    }
    if (!self.projectModel) {
        _projectModel = [[ProjectModel alloc] init];
        if (self.documentControllers) {
            for (DocumentController* dc in self.documentControllers) {
                if ([[[self.projectModel.documents allObjects] objectAtIndex:0] isEqual:dc.model]) {
                    [dc setWindowController:self.mainWindowController];
                }
            }
        }
    }
    
    return [super readFromURL:absoluteURL ofType:typeName error:error];
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"ProjectDocument dealloc");
#endif
}

@end
