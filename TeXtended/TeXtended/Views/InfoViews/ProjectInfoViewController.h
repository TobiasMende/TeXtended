//
//  ProjectInfoViewController.h
//  TeXtended
//
//  Created by Tobias Mende on 17.05.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ModelInfoViewController.h"
@class ProjectModel;

@interface ProjectInfoViewController : NSViewController <ModelInfoViewController,NSPathControlDelegate>

    @property (strong) IBOutlet NSPathControl *directoryPathControl;

    @property ProjectModel *model;


    - (IBAction)editPropertyFile:(id)sender;
@end
