//
//  StructureOutlineSectionViewController.m
//  TeXtended
//
//  Created by Tobias Mende on 26.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "StructureOutlineViewController.h"
#import <TMTHelperCollection/TMTLog.h>
#import <TMTHelperCollection/TMTTableView.h>
#import "StructurOutlineCellView.h"
#import "DocumentModel.h"
#import "Constants.h"
#import "DocumentCreationController.h"
#import "TMTNotificationCenter.h"
#import "OutlineElement.h"
#import "OutlineHelper.h"
@interface StructureOutlineViewController ()
- (void)jumpToSelection:(TMTTableView *)tableView;
- (void)outlineDidChange:(NSNotification *)note;
@end

@implementation StructureOutlineViewController

- (id)initWithRootNode:(DocumentModel *)model {
    self = [self initWithNibName:@"StructureOutlineView" bundle:nil];
    if (self) {
        self.rootNode = model;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(outlineDidChange:) name:TMTOutlineDidChangeNotification object:self.rootNode];
    }
    return self;
}

- (void)outlineDidChange:(NSNotification *)note {
    NSMutableArray *result = [OutlineHelper flatten:self.rootNode.outlineElements withPath:[NSMutableSet new]];
    [self performSelectorOnMainThread:@selector(setContent:) withObject:result waitUntilDone:YES];
}


- (void)loadView {
    [super loadView];
    self.content = [OutlineHelper flatten:self.rootNode.outlineElements withPath:[NSMutableSet new]];
    self.tableView.target = self;
    self.tableView.singleClickAction = @selector(jumpToSelection:);
    self.tableView.enterAction = @selector(jumpToSelection:);
}

- (void)jumpToSelection:(TMTTableView *)tableView {
    NSInteger row = tableView.selectedRow;
    
    if (row >= 0 && row < tableView.numberOfRows) {
        StructurOutlineCellView *view = [tableView viewAtColumn:0 row:row makeIfNecessary:NO];
        if (view) {
            NSString *path =view.element.document.texPath;
            NSUInteger line = view.element.line;
            [[DocumentCreationController sharedDocumentController] showTexDocumentForPath:path withReferenceModel:view.element.document andCompletionHandler:^(DocumentModel *model) {
                if (model) {
                    [[TMTNotificationCenter centerForCompilable:model] postNotificationName:TMTShowLineInTextViewNotification object:model userInfo:@{TMTIntegerKey: [NSNumber numberWithInteger:line]}];
                } else {
                    [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:path]];
                }
            }];
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table Delegate

@end
