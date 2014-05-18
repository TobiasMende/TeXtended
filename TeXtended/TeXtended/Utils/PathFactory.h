//
//  PathFactory.h
//  TeXtended
//
//  Created by Tobias Mende on 16.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 This class is a factory for getting pathes to different executables and directories used in this application
 
 **Author:** Tobias Mende
 
 */
@interface PathFactory : NSObject

/**
 Getter for the path to the texdoc executable
 
 @return the absolut path
 */
    + (NSString *)texdoc;

/**
 Getter for the path to the synctex executable
 
 @return the absolut path
 */
    + (NSString *)synctex;

/**
 Getter for the path to the lacheck executable
 
 @return the absolut path
 */
    + (NSString *)lacheck;

/**
 Getter for the path to the chktex executable
 
 @return the absolut path
 */
    + (NSString *)chktex;

/**
 Getter for the path to the texbin directory
 
 @return the absolut path
 */
    + (NSString *)texbin;


/**
 Method for creating a directory path if it didn't exist.
 
 @param path the path to the directory
 
 @return `YES` if a directory exists at the given path or could be created succesful, `NO` otherwise.
 */
    + (BOOL)checkForAndCreateFolder:(NSString *)path;

/**
 Method for extending a given path to get a temporary storage path
 @param path the path to extend
 
 @return a path containing the extension .TMTTemporaryStorage
 */
    + (NSString *)pathToTemporaryStorage:(NSString *)path;

/**
 Method for converting a temporary object path to a real object path
 @param temp the temporary path
 @return the real path
 
 */
    + (NSString *)realPathFromTemporaryStorage:(NSString *)temp;

    + (NSString *)absolutPathFor:(NSString *)path withBasedir:(NSString *)dir;
@end
