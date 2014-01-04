//
//  BibFile.h
//  TeXtended
//
//  Created by Tobias Mende on 01.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <TMTHelperCollection/FileObserver.h>

@class ProjectModel, GenericFilePresenter, TMTBibTexEntry;

/**
 Objects of this class are representations of the core data object representing a bib file.
 
 **Author:** Tobias Mende
 
 */

@interface BibFile : NSObject <NSCoding,FileObserver> {
    GenericFilePresenter *filePresenter;
}

/** the date of the last application internal read access to this file */
@property (strong) NSDate * lastRead;

@property NSNumber *fileEncoding;

/** The absolute path to the bib file */
@property (strong, nonatomic) NSString * path;

/** The project to which this entry belongs */
@property (assign) ProjectModel *project;

@property NSMutableArray *entries;

- (void)finishInitWithPath:(NSString *)absolutePath;

- (BOOL)insertEntry:(TMTBibTexEntry *)entry;

- (NSString *) loadFileContent;
- (BOOL) writeFileContent:(NSString *)content;
- (TMTBibTexEntry *)entryForCiteKey:(NSString *)key;
@end
