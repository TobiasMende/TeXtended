//
//  DocumentModel.h
//  TeXtended
//
//  Created by Tobias Mende on 01.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Compilable.h"

@class ProjectModel,OutlineElement;


/**
 Instances of this class represent a core data object containing information about a single latex file.
 
 **Author:** Tobias Mende
 
 */
@interface DocumentModel : Compilable {
    /** The pipes used for communication with the latex compiler */
    NSPipe *consoleOutputPipe, *consoleInputPipe;
    
    void (^removeLiveCompileObserver)(void);
    void (^removeOpenOnExportObserver)(void);
}

/** The date of the last application internal change of the represented file */
@property (nonatomic, strong) NSDate * lastChanged;

/** The date of the last compilation of the represented file */
@property (nonatomic, strong) NSDate * lastCompile;

/** The path to the output file (might be empty) */
@property (nonatomic, strong) NSString * pdfPath;

/** The path to the tex file */
@property (nonatomic, strong) NSString * texPath;

/** The system path to the tex file version storage.
 
 @warning Don't uses this if you are not exactly knowing about the purpose of this property.
 */
@property (nonatomic, strong) NSString * systemPath;

/** The NSTextEncoding of the file */
@property (nonatomic, strong) NSNumber *encoding;

/** Reference to the project containing this document. Might be empty if this document is handled in single document mode */
@property (nonatomic, strong) ProjectModel *project;

@property (nonatomic, strong) NSSet *outlineElements;

/** Flag determing whether live compile is active for this document or not */
@property (nonatomic, strong) NSNumber* liveCompile;

/** If on, the pdf is opened in the default pdf viewer after export */
@property (nonatomic, strong) NSNumber* openOnExport;

/**
 Method for loading the content of the represented file
 
 @return the files content
 */
- (NSString*) loadContent;

/**
 Method for saving new content to the represented file
 
 @param content the content to save
 @param error a reference to an error object in which to store erros occuring while saving.
 
 @return `YES` if the content was saved succesful, `NO` otherwise.
 */
- (BOOL) saveContent:(NSString*) content error:(NSError**) error;

/**
 Getter for the name of the texFile (only the last component of the texPath)
 
 @return the files name
 */
- (NSString *)texName;

/**
 Getter for the name of the pdf file (only the last component of the pdfPath)
 
 @return the files name
 */
- (NSString *)pdfName;


/**
 Getter for the output pipe
 
 @return the output pipe
 */
- (NSPipe*)consoleOutputPipe;

/**
 Getter for the input pipe
 
 @return the input pipe
 */
- (NSPipe*)consoleInputPipe;

/**
 Setter for the output pipe
 
 @param pipe the output pipe
 */
- (void)setConsoleOutputPipe:(NSPipe*)pipe;

/**
 Setter for the input pipe
 
 @param pipe the input pipe
 */
- (void)setConsoleInputPipe:(NSPipe*)pipe;

@end

@interface DocumentModel (CoreDataGeneratedAccessors)

- (void)addOutlineElementsObject:(OutlineElement *)value;
- (void)removeOutlineElementsObject:(OutlineElement *)value;
- (void)addOutlineElements:(NSSet *)values;
- (void)removeOutlineElements:(NSSet *)values;
@end


@interface DocumentModel (DocumentModelExtension)
- (void) initOutlineElements;
@end
