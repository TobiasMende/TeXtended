//
//  ProjectDocument.h
//  TeXtended
//
//  Created by Tobias Mende on 17.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainDocument.h"

/**
 The ProjectDocument is a NSDocument instance holding all information, model and controller connections for a project.
 In general a ProjectDocument has a single ProjectModel containing multiple DocumentModel and other attributes.
 
 **Author:** Tobias Mende
 
 */
@interface ProjectDocument : NSDocument<MainDocument>

@end
