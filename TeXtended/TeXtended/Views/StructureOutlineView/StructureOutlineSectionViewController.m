//
//  StructureOutlineSectionViewController.m
//  TeXtended
//
//  Created by Tobias Mende on 26.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "StructureOutlineSectionViewController.h"
#import <TMTHelperCollection/TMTLog.h>
#import <TMTHelperCollection/TMTTableView.h>
#import "StructurOutlineCellView.h"
#import "DocumentModel.h"
#import "Constants.h"
#import "DocumentCreationController.h"
#import "TMTNotificationCenter.h"
#import "OutlineElement.h"
@interface StructureOutlineSectionViewController ()
- (void)jumpToSelection:(TMTTableView *)tableView;
@end

@implementation StructureOutlineSectionViewController

- (id)initWithRootNode:(DocumentModel *)model {
    self = [super initWithNibName:@"StructureOutlineSectionView" bundle:nil];
    if (self) {
        self.rootNode = model;
    }
    return self;
}

- (void)loadView {
    [super loadView];
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
    DDLogVerbose(@"dealloc");
}

#pragma mark - Table Delegate

@end
