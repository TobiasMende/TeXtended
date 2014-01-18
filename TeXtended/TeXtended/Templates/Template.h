//
//  Template.h
//  TeXtended
//
//  Created by Tobias Mende on 18.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@class Compilable;
@interface Template : NSObject

@property NSString *info;
@property NSString *name;
@property NSMutableArray *tags;
@property TMTTemplateType type;
@property NSString *mainFileName;
@property Compilable *compilable;

- (BOOL) setDocumentWithContent:(NSString *)content model:(Compilable *)model andError:(NSError **)error;
- (BOOL) setProjectWithPath:(NSString *)projectPath model:(Compilable *)model andError:(NSError **)error;

- (BOOL) setContent:(NSString *)sourcePath  withError:(NSError **)error;
- (BOOL)packageExists;
- (NSString *)contentPath;
- (NSString *)templatePath;
- (BOOL)save:(NSError **)error;
- (NSDictionary *)configDictionary;
- (id)initWithDictionary:(NSDictionary *)config;
- (Compilable *)createInstanceWithName:(NSString *)name inDirectory:(NSString *)directory withError:(NSError **)error;

+ (Template *)templateFromFile:(NSString *)templatePath;

@end
