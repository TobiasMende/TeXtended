//
//  FolderSelectionViewController.m
//  TeXtended
//
//  Created by Max Bannach on 16.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "FolderSelectionViewController.h"
#import "ProjectModel.h"
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
            [self.view.window orderFront:nil];
        }
    }];
}

- (void)configureProjectModel:(ProjectModel *)project {
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir;
    if (self.path && [fm fileExistsAtPath:self.path isDirectory:&isDir] && isDir) {
        NSString *projectName = self.path.lastPathComponent;
        project.path = [self.path stringByAppendingPathComponent:[projectName stringByAppendingPathExtension:@"teXpf"]];
    }
}

@end
