//
//  BibFile.h
//  TeXtended
//
//  Created by Tobias Mende on 01.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TMTHelperCollection/FileObserver.h>

@class ProjectModel, GenericFilePresenter, TMTBibTexEntry;

/**
 * Objects of this class are representations of the core data object representing a bib file.
 *
 * **Author:** Tobias Mende
 *
 */

@interface BibFile : NSObject <NSCoding, FileObserver> {
	/** The presenter observes the file for changes made by other applications */
	GenericFilePresenter *filePresenter;
}

/** the date of the last application internal read access to this file */
@property (strong) NSDate *lastRead;

/** The encoding */
@property NSNumber *fileEncoding;

/** The absolute path to the bib file */
@property (strong, nonatomic) NSString *path;

/** The files name (last pathcomponent) */
@property (strong, readonly) NSString *name;

/** The project to which this entry belongs */
@property (assign) ProjectModel *project;

/** An array of citation entries in the current bib file (contains objects of type `TMTBibTexEntry`)
 * @see TMTHelperCollection/TMTBibTexEntry
 */
@property NSMutableArray *entries;

/**
 * This method is called after [BibFile initWithCoder:] with the absolute path to the project file. This is a good place to replace relative paths with absolute paths.
 *
 * @param absolutePath the absolute path to the project file
 */
- (void)finishInitWithPath:(NSString *)absolutePath;

/**
 * Inserts a new entry into the entries list and writes the file to disk
 *
 * @param entry the entry to append
 * @return `YES` if the file was written successfull, `NO` otherwise.
 *
 */
- (BOOL)insertEntry:(TMTBibTexEntry *)entry;

/**
 * Loads the content of the bibtex file
 * @return the file content or `nil`, if an error occured.
 */
- (NSString *)loadFileContent;

/**
 * Writes the given content into the bibtex file and replaces the current content.
 * @param content the content to write
 * @return `YES` if write was successfull, `NO` otherwise.
 */
- (BOOL)writeFileContent:(NSString *)content;

/**
 * Searches this bib file for the given cite key and returns the adjacent entry.
 * @param key the cite key
 * @return the entry belonging to the given cite key or `nil` if there isn't a matching key in this file.
 */
- (TMTBibTexEntry *)entryForCiteKey:(NSString *)key;
@end
