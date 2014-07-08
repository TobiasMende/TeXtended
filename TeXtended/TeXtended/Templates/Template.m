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

static const NSString *TMTTemplateInfoKey = @"TMTTemplateInfoKey";

static const NSString *TMTTemplateTagsKey = @"TMTTemplateCategoryKey";

static const NSString *TMTTemplateTypeKey = @"TMTTemplateTypeKey";

static const NSString *TMTTemplateCompilableKey = @"TMTTemplateCompilableKey";

static const NSString *TMTTemplateUidKey = @"TMTTemplateUidKey";

static const NSArray *EXCLUDED_FILE_NAMES;

static NSString *CONFIG_FILE_NAME = @"config.plist";

static NSString *PREVIEW_FILE_NAME = @"preview.pdf";

static NSString *CONTENT_DIR_NAME = @"content";

@interface Template ()

    - (BOOL)createContentDirectory:(NSError **)error;

    - (Compilable *)createProjectInstanceWithName:(NSString *)name inDirectory:(NSString *)directory withError:(NSError * __autoreleasing *)error;

    - (Compilable *)createDocumentInstanceWithName:(NSString *)name inDirectory:(NSString *)directory withError:(NSError * __autoreleasing *)error;

    - (NSString *)findPreviewPDFFor:(Compilable *)model atPath:(NSString *)directory;
@end

@implementation Template

+(void)initialize {
    if ([self class] == [Template class]) {
        EXCLUDED_FILE_NAMES = @[@".ds_store"];

    }
}

    - (id)initWithDictionary:(NSDictionary *)config name:(NSString *)name andCategory:(NSString *)category
    {
        self = [super init];
        if (self) {
            self.category = category;
            self.name = name;
            self.info = config[TMTTemplateInfoKey];
            self.uid = config[TMTTemplateUidKey] ? [config[TMTTemplateUidKey] integerValue] : -1;
            if (config[TMTTemplateCompilableKey]) {
                self.compilable = [NSKeyedUnarchiver unarchiveObjectWithData:config[TMTTemplateCompilableKey]];
            }
            self.type = [config[TMTTemplateTypeKey] longValue];
        }
        return self;
    }

    - (BOOL)save:(NSError **)error
    {
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

    - (Compilable *)createInstanceWithName:(NSString *)name inDirectory:(NSString *)directory withError:(NSError * __autoreleasing *)error
    {
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

    - (Compilable *)createDocumentInstanceWithName:(NSString *)name inDirectory:(NSString *)directory withError:(NSError * __autoreleasing *)error
    {
        self.mainFileName = @"main.tex";
        NSFileManager *fm = [NSFileManager defaultManager];

        DocumentModel *model = (DocumentModel *) [self.compilable copy];
        model.texPath = [name stringByAppendingPathExtension:@"tex"];
        model.pdfPath = [name stringByAppendingPathExtension:@"pdf"];
        [model finishInitWithPath:[directory stringByAppendingPathComponent:model.texPath]];
        if ([fm fileExistsAtPath:model.texPath]) {
            [fm removeItemAtPath:model.texPath error:NULL];
        }
        BOOL success = [fm copyItemAtPath:[self.contentPath stringByAppendingPathComponent:self.mainFileName] toPath:model.texPath error:error];
        NSArray *content = [fm contentsOfDirectoryAtPath:self.contentPath error:NULL];
        for (NSString *contentName in content) {
            if ([EXCLUDED_FILE_NAMES containsObject:contentName.lowercaseString]) {
                continue;
            }
            if (![contentName isEqualToString:self.mainFileName]) {
                [fm copyItemAtPath:[self.contentPath stringByAppendingPathComponent:contentName] toPath:[directory stringByAppendingPathComponent:contentName] error:NULL];
            }
        }
        if (success && self.hasPreviewPDF) {
            if ([fm fileExistsAtPath:model.pdfPath]) {
                [fm removeItemAtPath:model.pdfPath error:NULL];
            }
            success = [fm copyItemAtPath:self.previewPath toPath:model.pdfPath error:error];
        }

        if (!success) {
            return nil;
        }

        return model;
    }


    - (Compilable *)createProjectInstanceWithName:(NSString *)name inDirectory:(NSString *)directory withError:(NSError * __autoreleasing *)error
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        ProjectModel *model = (ProjectModel *) [self.compilable copy];

        NSArray *content = [fm contentsOfDirectoryAtPath:self.contentPath error:error];
        if (!content) {
            return nil;
        }
        BOOL success = YES;
        for (NSString *path in content) {
            if ([EXCLUDED_FILE_NAMES containsObject:path.lowercaseString]) {
                continue;
            }
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


    - (NSString *)findPreviewPDFFor:(Compilable *)model atPath:(NSString *)directory
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        for (DocumentModel *m in model.mainDocuments) {
            if (m.pdfPath && [fm fileExistsAtPath:m.pdfPath]) {
                return m.pdfPath;
            }
        }
        NSArray *content = [fm contentsOfDirectoryAtPath:directory error:nil];
        for (NSString *path in content) {
            if ([path.pathExtension.lowercaseString isEqualToString:@"pdf"]) {
                return [directory stringByAppendingPathComponent:path];
            }
        }
        return nil;
    }


    - (BOOL)setDocumentWithContent:(NSString *)content model:(DocumentModel *)model andError:(NSError * __autoreleasing *)error
    {
        if (error) {
            *error = nil;
        }
        self.compilable = [model copy];
        NSStringEncoding encoding = model.encoding.unsignedLongValue;
        if (encoding == 0) {
            encoding = NSUTF8StringEncoding;
            [(DocumentModel *) self.compilable setEncoding:@(encoding)];
        }
        self.mainFileName = @"main.tex";
        self.type = TMTDocumentTemplate;
        BOOL success = [self createContentDirectory:error];
        if (!success) {
            return success;
        }
        success = [content writeToFile:[self.contentPath stringByAppendingPathComponent:self.mainFileName] atomically:YES encoding:encoding error:error];
        NSString *pdfPath = nil;
        if (model.pdfPath) {
            pdfPath = [self findPreviewPDFFor:model atPath:[model.pdfPath stringByDeletingLastPathComponent]];
        }
        NSFileManager *fm = [NSFileManager defaultManager];
        if (success && pdfPath) {
            [fm removeItemAtPath:self.previewPath error:nil];
            success = [fm copyItemAtPath:pdfPath toPath:self.previewPath error:error];
        }
        if (success) {
            success = [self save:error];
        }
        return success;
    }

    - (BOOL)setProjectWithPath:(NSString *)projectPath model:(ProjectModel *)model andError:(NSError * __autoreleasing *)error
    {
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
            [fm removeItemAtPath:self.previewPath error:nil];
            success = [fm copyItemAtPath:pdfPath toPath:self.previewPath error:error];
        }
        if (success) {
            success = [self save:error];
        }
        return success;
    }

    - (BOOL)createContentDirectory:(NSError **)error
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:self.contentPath error:nil];
        BOOL success = [fm createDirectoryAtPath:self.contentPath withIntermediateDirectories:YES attributes:nil error:error];
        return success;
    }

#pragma mark - Getter & Setter

    - (NSString *)contentPath
    {
        return [self.templatePath stringByAppendingPathComponent:CONTENT_DIR_NAME];
    }

    - (NSDictionary *)configDictionary
    {
        return @{TMTTemplateInfoKey : self.info, TMTTemplateTypeKey : @(self.type), TMTTemplateCompilableKey : [NSKeyedArchiver archivedDataWithRootObject:self.compilable], TMTTemplateUidKey : @(self.uid)};
    }


    - (BOOL)packageExists
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        return [fm directoryExistsAtPath:self.templatePath];
    }


    - (NSString *)templatePath
    {
        NSString *applicationSupport = [ApplicationController userApplicationSupportDirectoryPath];


        return [[[applicationSupport stringByAppendingPathComponent:TMTTemplateDirectoryName] stringByAppendingPathComponent:self.category] stringByAppendingPathComponent:[self.name stringByAppendingPathExtension:TMTTemplateExtension]];
    }


    - (NSString *)previewPath
    {
        return [self.templatePath stringByAppendingPathComponent:PREVIEW_FILE_NAME];
    }

    - (BOOL)replacePreviewPdf:(NSString *)pdfPath
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        if (self.hasPreviewPDF) {
            [fm removeItemAtPath:self.previewPath error:NULL];
        }

        return [fm copyItemAtPath:pdfPath toPath:self.previewPath error:NULL];
    }


    - (BOOL)hasPreviewPDF
    {
        return [[NSFileManager defaultManager] fileExistsAtPath:self.previewPath];
    }

    - (BOOL)remove:(NSError * __autoreleasing *)error
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        return [fm removeItemAtPath:self.templatePath error:error];
    }

    - (BOOL)rename:(NSString *)newName withError:(NSError **)error;
    {
        if ([self.name isEqualToString:newName]) {
            return YES;
        }
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *applicationSupport = [ApplicationController userApplicationSupportDirectoryPath];


        NSString *destPath = [[[applicationSupport stringByAppendingPathComponent:TMTTemplateDirectoryName] stringByAppendingPathComponent:self.category] stringByAppendingPathComponent:[newName stringByAppendingPathExtension:TMTTemplateExtension]];
        BOOL success = [fm moveItemAtPath:self.templatePath toPath:destPath error:error];
        if (success) {
            self.name = newName;
        }

        return success;
    }


#pragma mark - Static Methods

    + (Template *)templateFromFile:(NSString *)templatePath
    {
        NSString *configPath = [templatePath stringByAppendingPathComponent:CONFIG_FILE_NAME];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:configPath];
        NSString *category = [templatePath.pathComponents objectAtIndex:templatePath.pathComponents.count - 2];
        return [[Template alloc] initWithDictionary:dict name:templatePath.lastPathComponent.stringByDeletingPathExtension andCategory:category];
    }

@end
