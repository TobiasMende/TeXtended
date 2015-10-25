//
// Created by Tobias Mende on 25.10.15.
// Copyright (c) 2015 Tobias Mende. All rights reserved.
//

#import "CompilerArgumentBuilder.h"
#import "CompileSetting.h"
#import "DocumentModel.h"
#import "ConsoleData.h"


@interface CompilerArgumentBuilder ()
- (void)addCompileSettingArguments:(NSMutableArray *)arguments;

- (void)addCustomArgument:(NSMutableArray *)arguments;

- (void)addPathArguments:(NSMutableArray *)arguments;
@end

@implementation CompilerArgumentBuilder {
    ConsoleData *_data;
}
- (id)initWithData:(ConsoleData *)data {
    self = [super init];
    if(self) {
        self->_data = data;
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
    [arguments addObject:_data.compileSetting.numberOfCompiles.stringValue];
    [arguments addObject:@(_data.compileMode).stringValue];
    [arguments addObject:_data.compileSetting.compileBib.stringValue];
}

- (void)addCustomArgument:(NSMutableArray *)arguments {
    if (_data.compileSetting.customArgument && _data.compileSetting.customArgument.length > 0) {
        [arguments addObject:[NSString stringWithFormat:@"\"%@\"", _data.compileSetting.customArgument]];
    }
}

- (void)addPathArguments:(NSMutableArray *)arguments {
    [arguments addObject:[_data.model.texPath stringByDeletingPathExtension]];
    [arguments addObject:_data.model.pdfPath];
}
@end