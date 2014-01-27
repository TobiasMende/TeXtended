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
- (void)outlineDidChange:(NSNotification *)note;
- (NSMutableArray *)flatten:(NSArray *)currentLevel withPath:(NSMutableSet *)path;
@end

@implementation StructureOutlineSectionViewController

- (id)initWithRootNode:(DocumentModel *)model {
    self = [super initWithNibName:@"StructureOutlineSectionView" bundle:nil];
    if (self) {
        self.rootNode = model;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(outlineDidChange:) name:TMTOutlineDidChangeNotification object:self.rootNode];
        self.content =[self flatten:self.rootNode.outlineElements withPath:[NSMutableSet new]];
    }
    return self;
}

- (void)outlineDidChange:(NSNotification *)note {
    NSMutableArray *result = [self flatten:self.rootNode.outlineElements withPath:[NSMutableSet new]];
    [self performSelectorOnMainThread:@selector(setContent:) withObject:result waitUntilDone:YES];
}


- (NSMutableArray *)flatten:(NSArray *)currentLevel withPath:(NSMutableSet *)path{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:currentLevel.count];
    for(OutlineElement *obj in currentLevel) {
        [result addObject:obj];
        if ([obj children] && [obj children].count > 0) {
            if (![path containsObject:obj]) {
                [path addObject:obj];
                [result addObjectsFromArray:[self flatten:[obj children] withPath:path]];
                [path removeObject:obj];
            }else {
                DDLogError(@"Tree contains loop. Breaking loop");
            }
        }
    }
    return result;
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    DDLogVerbose(@"dealloc");
}

#pragma mark - Table Delegate

@end
