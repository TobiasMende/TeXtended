//
//  MainDocument.m
//  TeXtended
//
//  Created by Tobias Mende on 02.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "MainDocument.h"
#import "Compilable.h"
#import "DocumentModel.h"
#import "DocumentController.h"
#import "MainWindowController.h"
#import "TMTLog.h"

@implementation MainDocument

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
    }
    return self;
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController
{
    if (!self.documentControllers || self.documentControllers.count == 0) {
        [self initializeDocumentControllers];
    }
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
    
    if ([windowController isKindOfClass:[MainWindowController class]]) {
        for(DocumentController *dc in self.documentControllers) {
            [self.mainWindowController showDocument:dc];
        }
    }
    
}


- (void)saveEntireDocumentWithDelegate:(id)delegate andSelector:(SEL)action {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (Compilable *)model {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

+ (BOOL)autosavesInPlace
{
    return YES;
    
}


- (void)initializeDocumentControllers {
    DDLogVerbose(@"initializeDocumentControllers");
    self.documentControllers = [NSMutableSet new];
    for (DocumentModel *m in self.model.mainDocuments) {
        DocumentController *dc = [[DocumentController alloc] initWithDocument:m andMainDocument:self];
        [self.documentControllers addObject:dc];
    }
}


- (void)makeWindowControllers {
    DDLogVerbose(@"makeWindowControllers");
    MainWindowController *mc = [[MainWindowController alloc] initForDocument:self];
    [self addWindowController:mc];
    self.mainWindowController = mc;
}

@end
