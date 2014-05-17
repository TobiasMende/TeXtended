//
//  ProjectInfoViewController.m
//  TeXtended
//
//  Created by Tobias Mende on 17.05.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "ProjectInfoViewController.h"

@interface ProjectInfoViewController ()
- (void)showDirectory:(id)sender;
@end

@implementation ProjectInfoViewController

- (id)init {
    self = [super initWithNibName:@"ProjectInfoView" bundle:nil];
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.directoryPathControl setDoubleAction:@selector(showDirectory:)];
    [self.directoryPathControl setTarget:self];
}

- (void)showDirectory:(id)sender {
    NSPathComponentCell *cell = self.directoryPathControl.clickedPathComponentCell;
    [[NSWorkspace sharedWorkspace] openFile:cell.URL.path];
}
@end
