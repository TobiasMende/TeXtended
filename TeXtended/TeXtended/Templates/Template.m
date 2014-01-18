//
//  Template.m
//  TeXtended
//
//  Created by Tobias Mende on 18.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "Template.h"
#import "ApplicationController.h"
#import "NSFileManager+TMTExtension.h"
#import "Compilable.h"
#import "ProjectModel.h"
#import "DocumentModel.h"
#import <Quartz/Quartz.h>
#import <TMTHelperCollection/TMTLog.h>
static const NSString *TMTTemplateInfoKey = @"TMTTemplateInfoKey";
static const NSString *TMTTemplateTagsKey = @"TMTTemplateCategoryKey";
static const NSString *TMTTemplateTypeKey = @"TMTTemplateTypeKey";
static const NSString *TMTTemplateCompilableKey = @"TMTTemplateCompilableKey";
static NSString *CONFIG_FILE_NAME = @"config.plist";
static NSString *PREVIEW_FILE_NAME = @"preview.pdf";
static NSString *CONTENT_DIR_NAME = @"content";

@interface Template ()
- (BOOL)createContentDirectory:(NSError **)error;
- (Compilable *)createProjectInstanceWithName:(NSString *)name inDirectory:(NSString *)directory withError:(NSError *__autoreleasing *)error;
- (Compilable *)createDocumentInstanceWithName:(NSString *)name inDirectory:(NSString *)directory withError:(NSError *__autoreleasing *)error;
- (NSString *)findPreviewPDFFor:(Compilable *)model atPath:(NSString *)directory;
@end

@implementation Template

- (id)initWithDictionary:(NSDictionary *)config andCategory:(NSString *)category {
    self = [super init];
    if (self) {
        self.category = category;
        self.info = config[TMTTemplateInfoKey];
        self.compilable = config[TMTTemplateCompilableKey];
        self.type = [config[TMTTemplateTypeKey] longValue];
    }
    return self;
}

- (BOOL)save:(NSError**)error {
    BOOL success;
    if (!self.packageExists) {
        NSFileManager *fm = [NSFileManager defaultManager];
        success = [fm createDirectoryAtPath:self.templatePath withIntermediateDirectories:YES attributes:nil error:error];
        if (!success) {
            return success;
        }
    }
    success = [self.configDictionary writeToFile:[self.templatePath stringByAppendingPathComponent:CONFIG_FILE_NAME] atomically:YES];
    
    return success;
    
}

- (Compilable *)createInstanceWithName:(NSString *)name inDirectory:(NSString *)directory withError:(NSError *__autoreleasing *)error {
    Compilable *compilable = nil;
    switch (self.type) {
        case TMTDocumentTemplate:
            compilable = [self createDocumentInstanceWithName:name inDirectory:directory withError:error];
            break;
        case TMTProjectTemplate:
            compilable = [self createProjectInstanceWithName:name inDirectory:directory withError:error];
            break;
        default:
            break;
    }
    return compilable;
}

- (Compilable *)createDocumentInstanceWithName:(NSString *)name inDirectory:(NSString *)directory withError:(NSError *__autoreleasing *)error {
    NSFileManager *fm = [NSFileManager defaultManager];
    DocumentModel *model = (DocumentModel *)[self.compilable copy];
    model.texPath = [directory stringByAppendingPathComponent:[name stringByAppendingPathExtension:@"tex"]];
    BOOL success = [fm copyItemAtPath:[self.contentPath stringByAppendingPathComponent:self.mainFileName] toPath:model.texPath error:error];
    if (success && self.hasPreviewPDF) {
        success = [fm copyItemAtPath:self.previewPath toPath:model.pdfPath error:error];
    }
    
    if (!success) {
        return nil;
    }
    
    return model;
}


- (Compilable *)createProjectInstanceWithName:(NSString *)name inDirectory:(NSString *)directory withError:(NSError *__autoreleasing *)error {
    NSFileManager *fm = [NSFileManager defaultManager];
    ProjectModel *model = (ProjectModel *)[self.compilable copy];
    
    NSArray *content = [fm contentsOfDirectoryAtPath:self.contentPath error:error];
    if (!content) {
        return nil;
    }
    BOOL success = YES;
    for (NSString *path in content) {
        success = [fm copyItemAtPath:[self.contentPath stringByAppendingPathComponent:path] toPath:[directory stringByAppendingPathComponent:path] error:error];
        if (!success) {
            return nil;
        }
    }
    [model finishInitWithPath:[directory stringByAppendingPathComponent:[name stringByAppendingPathExtension:TMTProjectFileExtension]]];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
    success = [data writeToFile:model.path atomically:YES];
    if (!success) {
        return nil;
    }
    return model;
}


- (NSString *)findPreviewPDFFor:(Compilable *)model atPath:(NSString *)directory {
    NSFileManager *fm = [NSFileManager defaultManager];
    for(DocumentModel *m in model.mainDocuments) {
        if (m.pdfPath && [fm fileExistsAtPath:m.pdfPath]) {
            return m.pdfPath;
        }
    }
    NSArray *content = [fm contentsOfDirectoryAtPath:directory error:nil];
    for(NSString *path in content) {
        if ([path.pathExtension.lowercaseString isEqualToString:@"pdf"]) {
            return [directory stringByAppendingPathComponent:path];
        }
    }
    return nil;
}


- (BOOL)setDocumentWithContent:(NSString *)content model:(DocumentModel *)model andError:(NSError *__autoreleasing *)error {
    self.compilable = [model copy];
    self.mainFileName = @"main.tex";
    self.type = TMTDocumentTemplate;
    BOOL success = [self createContentDirectory:error];
    if (!success) {
        return success;
    }
    success = [content writeToFile:[content stringByAppendingString:self.mainFileName] atomically:YES encoding:model.encoding.unsignedLongValue error:error];
    NSString *pdfPath = nil;
    if (model.pdfPath) {
        pdfPath= [self findPreviewPDFFor:model atPath:[model.pdfPath stringByDeletingLastPathComponent]];
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    if (success && pdfPath) {
        success = [fm copyItemAtPath:pdfPath toPath:self.previewPath error:error];
    }
    if (success) {
        success = [self save:error];
    }
    return success;
}

- (BOOL)setProjectWithPath:(NSString *)projectPath model:(ProjectModel *)model andError:(NSError *__autoreleasing *)error {
    self.compilable = [model copy];
    self.mainFileName = [projectPath lastPathComponent];
    self.type = TMTProjectTemplate;
    BOOL success = [self createContentDirectory:error];
    if (!success) {
        return success;
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *directory = [projectPath stringByDeletingLastPathComponent];
    NSArray *contentToCopy = [fm contentsOfDirectoryAtPath:directory error:error];
    NSString *pdfPath = [self findPreviewPDFFor:model atPath:directory];
    success = YES;
    for (NSString *path in contentToCopy) {
        if ([path.pathExtension.lowercaseString isEqualToString:TMTProjectFileExtension.lowercaseString] || [[NSFileManager temporaryFileExtensions] containsObject:path.pathExtension] || [path isEqualToString:pdfPath.lastPathComponent]) {
            continue;
        }
        success = [fm copyItemAtPath:[directory stringByAppendingPathComponent:path] toPath:[self.contentPath stringByAppendingPathComponent:path] error:error];
        if (!success) {
            break;
        }
    }
    if (success) {
        success = [fm copyItemAtPath:pdfPath toPath:[self.templatePath stringByAppendingPathComponent:PREVIEW_FILE_NAME] error:error];
    }
    if (success) {
        success = [self save:error];
    }
    return success;
}

- (BOOL)createContentDirectory:(NSError **)error {
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:self.contentPath error:nil];
    BOOL success = [fm createDirectoryAtPath:self.contentPath withIntermediateDirectories:YES attributes:nil error:error];
    return success;
}

#pragma mark - Getter & Setter

- (NSString *)contentPath {
    return [self.templatePath stringByAppendingPathComponent:CONTENT_DIR_NAME];
}

- (NSDictionary *)configDictionary {
    return @{TMTTemplateInfoKey: self.info, TMTTemplateTypeKey: @(self.type), TMTTemplateCompilableKey: self.compilable};
}


- (BOOL)packageExists {
    NSFileManager *fm = [NSFileManager defaultManager];
    return [fm directoryExistsAtPath:self.templatePath];
}


- (NSString *)templatePath {
    NSString *applicationSupport = [ApplicationController userApplicationSupportDirectoryPath];
    
    
    return [[[applicationSupport stringByAppendingPathComponent:TMTTemplateDirectoryName] stringByAppendingPathComponent:self.category ] stringByAppendingPathComponent:[self.name stringByAppendingPathExtension:TMTTemplateExtension]];
}

- (PDFDocument *)previewPDF {
    if (self.hasPreviewPDF) {
        NSURL *pdfUrl = [NSURL fileURLWithPath:self.previewPath];
        PDFDocument *doc = [[PDFDocument alloc] initWithURL:pdfUrl];
        return doc;
    }
    return nil;
}

- (NSString *)previewPath {
    return [self.templatePath stringByAppendingPathComponent:PREVIEW_FILE_NAME];
}


- (BOOL)hasPreviewPDF {
    return [[NSFileManager defaultManager] fileExistsAtPath:self.previewPath ];
}


#pragma mark - Static Methods

+ (Template *)templateFromFile:(NSString *)templatePath {
    NSString *configPath = [templatePath stringByAppendingPathComponent:CONFIG_FILE_NAME];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:configPath];
    NSString *category = [templatePath.pathComponents objectAtIndex:templatePath.pathComponents.count-2];
    return [[Template alloc] initWithDictionary:dict andCategory:category];
}

@end
