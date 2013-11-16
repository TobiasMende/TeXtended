//
//  FolderSelectionViewController.m
//  TeXtended
//
//  Created by Max Bannach on 16.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "FolderSelectionViewController.h"

@interface FolderSelectionViewController ()

@end

@implementation FolderSelectionViewController

- (id)init {
    self = [super initWithNibName:@"FolderSelectionView" bundle:nil];
    if (self) {
        
    }
    return self;
}

- (IBAction)select:(id)sender {
    NSOpenPanel *panel = [[NSOpenPanel alloc] init];
    
    panel.canChooseFiles = NO;
    panel.canChooseDirectories = YES;
    panel.title = NSLocalizedString(@"Choose Project Folder", @"Choose Project Folder");
    panel.canCreateDirectories = YES;
    
    [panel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSURL *directory = [panel URL];
            self.path = [directory path];
        }
    }];
}

@end
