//
// Created by Tobias Mende on 25.10.15.
// Copyright (c) 2015 Tobias Mende. All rights reserved.
//

#import "CompilerArgumentBuilder.h"
#import "CompileSetting.h"
#import "DocumentModel.h"
#import "ConsoleData.h"


@implementation CompilerArgumentBuilder {
    ConsoleData *data;
}
- (id)initWithData:(ConsoleData *)data {
    self = [super init];
    if(self) {
        self->data = data;
    }
    return self;
}

- (NSArray *)build {
    NSMutableArray *arguments = [NSMutableArray new];
    [self addPathArguments:arguments];
    [self addCompileSettingArguments:arguments];
    [self addCustomArgument:arguments];
    return arguments;
}

- (void)addCompileSettingArguments:(NSMutableArray *)arguments {
    [arguments addObject:data.compileSetting.numberOfCompiles.stringValue];
    [arguments addObject:@(data.compileMode).stringValue];
    [arguments addObject:data.compileSetting.compileBib.stringValue];
}

- (void)addCustomArgument:(NSMutableArray *)arguments {
    if (data.compileSetting.customArgument && data.compileSetting.customArgument.length > 0) {
        [arguments addObject:[NSString stringWithFormat:@"\"%@\"", data.compileSetting.customArgument]];
    }
}

- (void)addPathArguments:(NSMutableArray *)arguments {
    [arguments addObject:[data.model.texPath stringByDeletingPathExtension]];
    [arguments addObject:data.model.pdfPath];
}
@end