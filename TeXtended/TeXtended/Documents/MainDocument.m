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
#import "ExportCompileWindowController.h"
#import "StatsPanelController.h"
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

- (void)finalCompileForDocumentController:(DocumentController *)dc {
    if (!exportWindowController) {
        exportWindowController = [[ExportCompileWindowController alloc] initWithMainDocument:self];
    }
    exportWindowController.documentController = dc;
    [exportWindowController showWindow:nil];
}

- (void)showStatisticsForModel:(DocumentController *)dc {
    if (!statisticPanelController) {
        statisticPanelController = [StatsPanelController new];
    }
    [statisticPanelController showStatistics:dc.model.texPath];
}

- (void)openNewTabForCompilable:(Compilable*)model {
    for (DocumentController *dc in self.documentControllers) {
        if (dc.model == model) {
            return;
        }
    }
    
    DocumentController *dc = [[DocumentController alloc] initWithDocument:model andMainDocument:self];
    [self.documentControllers addObject:dc];
    [self.mainWindowController showDocument:dc];
}

@end
