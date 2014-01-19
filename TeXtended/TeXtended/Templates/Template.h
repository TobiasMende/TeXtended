//
//  Template.h
//  TeXtended
//
//  Created by Tobias Mende on 18.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@class Compilable, DocumentModel, ProjectModel, PDFDocument;
@interface Template : NSObject

@property NSString *info;
@property NSString *name;
@property NSString *category;
@property TMTTemplateType type;
@property NSString *mainFileName;
@property Compilable *compilable;

- (BOOL) setDocumentWithContent:(NSString *)content model:(DocumentModel *)model andError:(NSError **)error;
- (BOOL) setProjectWithPath:(NSString *)projectPath model:(ProjectModel *)model andError:(NSError **)error;

- (BOOL)packageExists;
- (NSString *)contentPath;
- (NSString *)templatePath;
- (BOOL)save:(NSError **)error;
- (NSDictionary *)configDictionary;
- (Compilable *)createInstanceWithName:(NSString *)name inDirectory:(NSString *)directory withError:(NSError **)error;

- (NSString *)previewPath;
- (BOOL) hasPreviewPDF;

+ (Template *)templateFromFile:(NSString *)templatePath;

- (id)initWithDictionary:(NSDictionary *)config name:(NSString *)name andCategory:(NSString *)category;

- (BOOL)remove:(NSError **)error;
- (BOOL)rename:(NSString *)newName  withError:(NSError **)error;
- (BOOL) replacePreviewPdf:(NSString *)pdfPath;
@end
