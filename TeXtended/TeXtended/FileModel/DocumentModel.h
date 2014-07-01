//
//  DocumentModel.h
//  TeXtended
//
//  Created by Tobias Mende on 01.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "Compilable.h"

#import <Foundation/Foundation.h>

@class ProjectModel, OutlineElement, OutlineExtractor;
@class GenericFilePresenter;
@protocol FileObserver;

/**
 * Instances of this class represent a core data object containing information about a single latex file.
 *
 * **Author:** Tobias Mende
 *
 */
@interface DocumentModel : Compilable<FileObserver>
    {
        void (^removeLiveCompileObserver)(void);

        void (^removeOpenOnExportObserver)(void);

        DocumentModel *_currentMainDocument;

        NSMutableDictionary *globalMessagesMap;

        GenericFilePresenter *_filePresenter;
    }

#pragma mark - Properties

/** The date of the last compilation of the represented file */
    @property (strong) NSDate *lastCompile;

/** Reference to the project containing this document. Might be empty if this document is handled in single document mode */
    @property (assign) ProjectModel *project;

/** The path to the output file (might be empty) */
    @property (nonatomic, strong) NSString *pdfPath;

/** The path to the tex file */
    @property (nonatomic, strong) NSString *texPath;

/** Flag determing whether live compile is active for this document or not */
    @property (nonatomic, strong) NSNumber *liveCompile;

/** If on, the pdf is opened in the default pdf viewer after export */
    @property (nonatomic, strong) NSNumber *openOnExport;

    @property BOOL isCompiling;
    @property (getter=isDocumentOpened) BOOL documentOpened;

    @property NSArray *messages;

    @property NSSet *lineBookmarks;
    @property NSRange selectedRange;

    @property (nonatomic, strong) NSArray *outlineElements;

#pragma mark Readonly Properties

    @property (readonly) NSString *texIdentifier;

    @property (readonly) NSString *pdfIdentifier;


#pragma mark System Properties

/** The system path to the tex file version storage.
 *
 * @warning Don't uses this if you are not exactly knowing about the purpose of this property.
 */
    @property (strong) NSString *systemPath;

    @property NSPipe *consoleOutputPipe;

    @property NSPipe *consoleInputPipe;


#pragma mark - Loading & Saving
/**
 * Method for loading the content of the represented file
 *
 * @return the files content
 */
    - (NSString *)loadContent:(__autoreleasing NSError **)error;

/**
 * Method for saving new content to the represented file
 *
 * @param content the content to save
 * @param error a reference to an error object in which to store erros occuring while saving.
 *
 * @return `YES` if the content was saved succesful, `NO` otherwise.
 */
    - (BOOL)saveContent:(NSString *)content error:(__autoreleasing NSError **)error;


#pragma mark -  Getter

    - (DocumentModel *)currentMainDocument;

    - (NSString *)header;

/**
 * Getter for the name of the pdf file (only the last component of the pdfPath)
 *
 * @return the files name
 */
    - (NSString *)pdfName;

/**
 * Getter for the name of the texFile (only the last component of the texPath)
 *
 * @return the files name
 */
    - (NSString *)texName;


#pragma mark - Setter

    - (void)setCurrentMainDocument:(DocumentModel *)cmd;


#pragma mark - Message Handling

    - (void)updateMessages:(NSArray *)messages forType:(TMTMessageGeneratorType)type;

    - (NSArray *)mergedGlobalMessages;


#pragma mark - Outline Handling

    - (void)buildOutline;
@end

