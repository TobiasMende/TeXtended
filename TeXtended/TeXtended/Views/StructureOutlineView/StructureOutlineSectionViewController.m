//
//  StructureOutlineSectionViewController.m
//  TeXtended
//
//  Created by Tobias Mende on 26.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "StructureOutlineSectionViewController.h"
#import <TMTHelperCollection/TMTLog.h>
#import "DocumentModel.h"
@interface StructureOutlineSectionViewController ()

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
    
    DDLogVerbose(@"%@", self.rootNode.outlineElements);
}


- (void)dealloc {
    DDLogVerbose(@"dealloc");
}

#pragma mark - Outline Delegate

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldCollapseItem:(id)item {
    return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldExpandItem:(id)item {
    return YES;
}

-(BOOL)outlineView:(NSOutlineView *)outlineView shouldShowOutlineCellForItem:(id)item {
    return YES;
}

@end
