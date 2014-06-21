//
//  ProjectCreationAssistantViewController.h
//  TeXtended
//
//  Created by Tobias Mende on 16.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ProjectModel;

@protocol ProjectCreationAssistantViewController <NSObject>

    - (void)configureProjectModel:(ProjectModel *)project;
@end
