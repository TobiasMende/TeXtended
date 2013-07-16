//
//  FileViewModel.h
//  TeXtended
//
//  Created by Tobias Hecht on 15.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DocumentModel;

/**
 The FilewViewModel holds all the important content and information about the files represented by the FileViewModel. The FileViewModel is hierarchically ordered ad a tree structure. Moreover, the FileViewModel is used as items for the data source of the FileOutlineView within the FileView.
 
 **Author:** Tobias Hecht
 */

@interface FileViewModel : NSObject {
    /** Index of filename in the pathcomponents */
    NSInteger pathIndex;
    
    /** Array of fileviewmodels for children in hierarchy */
    NSMutableArray* children;
}

/** Documentmodel represented by fileviewmodel */
@property (strong) DocumentModel *docModel;
/** Parent of fileviewmodel in hierarchy */
@property (assign) FileViewModel *parent;
/** Filepath of file represented by fileviewmodel */
@property (nonatomic, strong) NSString *filePath;
/** Icon of file represented by fileviewmodel */
@property NSImage* icon;
/** Name of file represented by fileviewmodel */
@property NSString* fileName;
/** Components of path represented by fileviewmodel */
@property NSArray* pathComponents;
/** Flag to keep the information if the file represented by fileviewmodel is a directory */
@property BOOL isDir;
/** Flag to keep the information if the fileviewmodel is expandable */
@property BOOL expandable;

/** Add a new fileviewmodel to represent a new path
 @param path is the path to add
 */
-(FileViewModel*)addPath:(NSString*)path;
/** Adds a Documentmodel to the fileviewmodel specified by path 
 @param newModel is the Documentmodel
 @param path is the path to specify the fileviewmodel
 */
-(void)addDocumentModel:(DocumentModel*)newModel
                 atPath:(NSString*)path;
/** Adds a moved fileviewmodel to the set of children 
 @param newChildren is the moved fileviewmodel
 */
-(void)addExitsingChildren:(FileViewModel*)newChildren;
/** Changes the filename of fileviewmodel specified by oldPath to newName 
 @param oldPath is the path to specify the fileviewmodel
 @param newName is the new name of the fileviewmodel
 */
-(void)setFileName:(NSString*)oldPath
            toName:(NSString*)newName;
/** Change a path component of fileviewmodel 
 @param name is the new name of path component
 @param index is the index of the changing path component
 */
-(void)setFileNameOfParent:(NSString*)name
          atComponentIndex:(NSInteger)index;
/** Returns the fileviewmodel specified by name from the children set
 @param name is the name of the requested children
 
 return fileviewmodel of the requested children
 */
-(FileViewModel*)getChildrenByName:(NSString*)name;
/** Returns the fileviewmodel specified by index from the children set 
 @param index is the index of the requested children
 
 return fileviewmodel of the requested children
 */
-(FileViewModel*)getChildrenByIndex:(NSInteger)index;
/** Returns the number of children of the fileviewmodel 
 
 return Number of children
 */
-(NSInteger)numberOfChildren;
/** Requests through the hierarchy if the fileviewmodel at path is expandable 
 @param path is the filepath whose fileviewmodels expandable information is requested
 
 return expandable information
 */
-(BOOL)expandableAtPath:(NSString*)path;
/** Remove a children from the set of childrens */
-(void)removeChildren:(FileViewModel*) childrenModel;
/** Removes all fileviewmodels whose files does not exists anymore */
-(void)clean;
@end
