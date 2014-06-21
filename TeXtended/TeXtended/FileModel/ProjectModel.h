//
//  ProjectModel.h
//  TeXtended
//
//  Created by Tobias Mende on 01.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Compilable.h"

@class BibFile, DocumentModel;


/**
 * The ProjectModel is the representation of the core data object for a project.
 *
 * **Author:** Tobias Mende
 *
 */
@interface ProjectModel : Compilable
    {
    }

#pragma mark - Properties

/** The absolute path to the project file */
    @property (nonatomic, strong) NSString *path;

/** A set of all documents belonging to this project */
    @property (strong) NSMutableSet *documents;

/** The main properties of this project */
    @property (strong) DocumentModel *properties;


#pragma mark - Getter

    - (NSString *)folderPath;

@end
