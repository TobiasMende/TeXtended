//
//  Template.m
//  TeXtended
//
//  Created by Tobias Mende on 18.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "Template.h"
#import "ApplicationController.h"
#import "NSFileManager+DirectoryExtension.h"
#import "Compilable.h"
#import "ProjectModel.h"
#import "DocumentModel.h"
#import <TMTHelperCollection/TMTLog.h>
static const NSString *TMTTemplateInfoKey = @"TMTTemplateInfoKey";
static const NSString *TMTTemplateTagsKey = @"TMTTemplateTagsKey";
static const NSString *TMTTemplateTypeKey = @"TMTTemplateTypeKey";
static const NSString *TMTTemplateCompilableKey = @"TMTTemplateCompilableKey";
static NSString *TEMPLATE_EXTENSION = @"tmttemplate";
static NSString *TEMPLATE_FOLDER_NAME = @"templates";
static NSString *CONFIG_FILE_NAME = @"config.plist";
static NSString *CONTENT_DIR_NAME = @"content";

@interface Template ()
- (BOOL)createContentDirectory:(NSError **)error;
- (Compilable *)createProjectInstanceWithName:(NSString *)name inDirectory:(NSString *)directory withError:(NSError *__autoreleasing *)error;
- (Compilable *)createDocumentInstanceWithName:(NSString *)name inDirectory:(NSString *)directory withError:(NSError *__autoreleasing *)error;
@end

@implementation Template

- (id)initWithDictionary:(NSDictionary *)config {
    self = [super init];
    if (self) {
        self.info = config[TMTTemplateInfoKey];
        self.tags = config[TMTTemplateTagsKey];
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
        success = [fm copyItemAtPath:path toPath:[directory stringByAppendingPathComponent:path.lastPathComponent] error:error];
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



- (BOOL)setDocumentWithContent:(NSString *)content model:(Compilable *)model andError:(NSError *__autoreleasing *)error {
    self.compilable = model;
    self.mainFileName = @"main.tex";
    self.type = TMTDocumentTemplate;
    BOOL success = [self createContentDirectory:error];
    if (!success) {
        return success;
    }
    success = [content writeToFile:[content stringByAppendingString:self.mainFileName] atomically:YES encoding:model.encoding.unsignedLongValue error:error];
    if (success) {
        success = [self save:error];
    }
    return success;
}

- (BOOL)setProjectWithPath:(NSString *)projectPath model:(Compilable *)model andError:(NSError *__autoreleasing *)error {
    self.compilable = model;
    self.mainFileName = [projectPath lastPathComponent];
    self.type = TMTProjectTemplate;
    BOOL success = [self createContentDirectory:error];
    if (!success) {
        return success;
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *path = [projectPath stringByDeletingLastPathComponent];
    NSArray *contentToCopy = [fm contentsOfDirectoryAtPath:path error:error];
    success = YES;
    for (NSString *path in contentToCopy) {
        if ([[path pathExtension] isEqualToString:TMTProjectFileExtension]) {
            continue;
        }
        success = [fm copyItemAtPath:path toPath:[self.contentPath stringByAppendingPathComponent:[path lastPathComponent]] error:error];
        if (!success) {
            break;
        }
    }
    if (success) {
        success = [self save:error];
    }
    return success;
}

- (BOOL)setContent:(NSString *)sourcePath withError:(NSError **)error {
    self.mainFileName =[sourcePath lastPathComponent];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *contentPath = [self.templatePath stringByAppendingPathComponent:CONTENT_DIR_NAME];
    BOOL creationOk = [self createContentDirectory:error];
    if (!creationOk) {
        return NO;
    }
    NSArray *contentToCopy;
    if ([[sourcePath pathExtension] isEqualToString:TMTProjectFileExtension]) {
        // Project Mode
        self.type = TMTProjectTemplate;
        NSString *path = [sourcePath stringByDeletingLastPathComponent];
        contentToCopy = [fm contentsOfDirectoryAtPath:path error:error];
    } else {
        // Document Mode
        self.type = TMTDocumentTemplate;
        contentToCopy = @[sourcePath];
    }
    
    if (!contentToCopy) {
        DDLogError(@"Content seems to be nil");
        return NO;
    }
    BOOL success = YES;
    for (NSString *path in contentToCopy) {
        success = [fm copyItemAtPath:path toPath:contentPath error:error];
        if (!success) {
            break;
        }
    }
    if (success) {
        success = [self save:error];
    }
    return success;
}

- (BOOL)createContentDirectory:(NSError **)error {
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:self.contentPath error:error];
    BOOL success = [fm createDirectoryAtPath:self.contentPath withIntermediateDirectories:YES attributes:nil error:error];
    return success;
}

#pragma mark - Getter & Setter

- (NSString *)contentPath {
    return [self.templatePath stringByAppendingPathComponent:CONTENT_DIR_NAME];
}

- (NSDictionary *)configDictionary {
    return @{TMTTemplateInfoKey: self.info, TMTTemplateTagsKey: self.tags, TMTTemplateTypeKey: @(self.type), TMTTemplateCompilableKey: self.compilable};
}


- (BOOL)packageExists {
    NSFileManager *fm = [NSFileManager defaultManager];
    return [fm directoryExistsAtPath:self.templatePath];
}


- (NSString *)templatePath {
    NSString *applicationSupport = [ApplicationController userApplicationSupportDirectoryPath];
    return [[applicationSupport stringByAppendingPathComponent:TEMPLATE_FOLDER_NAME] stringByAppendingPathComponent:[self.name stringByAppendingPathExtension:TEMPLATE_EXTENSION]];
}

#pragma mark - Static Methods

+ (Template *)templateFromFile:(NSString *)templatePath {
    NSString *configPath = [templatePath stringByAppendingPathComponent:CONFIG_FILE_NAME];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:configPath];
    return [[Template alloc] initWithDictionary:dict];
}

@end
