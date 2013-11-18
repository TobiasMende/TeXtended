//
//  FolderSelectionViewController.h
//  TeXtended
//
//  Created by Max Bannach on 16.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ProjectCreationAssistantViewController.h"

@interface FolderSelectionViewController : NSViewController<ProjectCreationAssistantViewController>

@property (strong) NSString *path;
- (IBAction)select:(id)sender;

@end
