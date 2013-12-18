//
//  BibFile.h
//  TeXtended
//
//  Created by Tobias Mende on 01.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ProjectModel;

/**
 Objects of this class are representations of the core data object representing a bib file.
 
 **Author:** Tobias Mende
 
 */

@interface BibFile : NSObject <NSCoding, NSFilePresenter> {
    NSFileCoordinator *coordinator;
}

/** the date of the last application internal read access to this file */
@property (strong) NSDate * lastRead;

/** The absolute path to the bib file */
@property (strong, nonatomic) NSString * path;

/** The project to which this entry belongs */
@property (weak) ProjectModel *project;

@property NSMutableArray *entries;

@property (readonly) NSURL *presentedItemURL;

@property (readonly) NSOperationQueue *presentedItemOperationQueue;


@end
