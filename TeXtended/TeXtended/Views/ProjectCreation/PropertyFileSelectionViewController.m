//
//  PropertyFileSelectionViewController.m
//  TeXtended
//
//  Created by Tobias Mende on 16.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "PropertyFileSelectionViewController.h"

@interface PropertyFileSelectionViewController ()

@end

@implementation PropertyFileSelectionViewController

- (id)init {
    self = [super initWithNibName:@"PropertyFileSelectionView" bundle:nil];
    return self;
}

- (IBAction)select:(id)sender {
    NSOpenPanel *panel = [[NSOpenPanel alloc] init];
    
    panel.canChooseFiles = YES;
    panel.canChooseDirectories = NO;
    panel.title = NSLocalizedString(@"Choose Properties File", @"Choose Properties File");
    panel.canCreateDirectories = NO;
    
    [panel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSURL *directory = [panel URL];
            self.filePath = [directory path];
        }
    }];
    
}

@end
