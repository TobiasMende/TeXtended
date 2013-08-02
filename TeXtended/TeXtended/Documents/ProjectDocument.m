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
    
    for (DocumentController* dc in self.documentControllers) {
        if ([[[self.projectModel.documents allObjects] objectAtIndex:0] isEqual:dc.model]) {
            [dc setWindowController:self.mainWindowController];
        }
    }
}

- (BOOL)writeToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation originalContentsURL:(NSURL *)absoluteOriginalContentsURL error:(NSError *__autoreleasing *)error {
    
    /* save all documents */
    for (DocumentController* dc in self.documentControllers) {
        [dc saveDocument:error];
    }
    
    
    
    return [super writeToURL:absoluteURL ofType:typeName forSaveOperation:saveOperation originalContentsURL:absoluteOriginalContentsURL error:error];
}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError *__autoreleasing *)error {

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
