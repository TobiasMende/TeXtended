//
//  ProjectInfoViewController.m
//  TeXtended
//
//  Created by Tobias Mende on 17.05.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "ProjectInfoViewController.h"
#import "ProjectModel.h"
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
- (IBAction)editPropertyFile:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.canChooseFiles = YES;
    panel.canChooseDirectories = NO;
    panel.message = NSLocalizedString(@"Choose a proprty file:", @"");
    panel.prompt = NSLocalizedString(@"Update", @"Update property file button");
    panel.canCreateDirectories = NO;
    panel.allowedFileTypes = @[@"tex"];
    
    [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSURL *url = [panel URL];
            self.model.properties = [self.model modelForTexPath:url.path byCreating:YES];
            [self.view.window orderFront:nil];
        }
    }];
}
@end
