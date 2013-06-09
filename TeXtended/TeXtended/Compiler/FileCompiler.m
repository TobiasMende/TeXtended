//
//  FileCompiler.m
//  TeXtended
//
//  Created by Max Bannach on 09.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "FileCompiler.h"
#import "DocumentModel.h"
#import "CompileFlowHandler.h"
#import "CompileSetting.h"
#import "Constants.h"

@implementation FileCompiler

- (id) initWithDocumentModel:(DocumentModel*) model {
    self = [super init];
    if (self) {
        [self setAutoCompile:NO];
        _model = model;
    }
    return self;
}

- (void) compile:(bool)draft {
  
        CompileSetting *settings;
        NSTask *task   = [[NSTask alloc] init];
        [self model].outputPipe = [NSPipe pipe];
        [self model].inputPipe = [NSPipe pipe];
        [task setStandardOutput:[self model].outputPipe];
        [task setStandardInput:[self model].inputPipe];
        NSString *path;
        
        if (draft) {
            settings = [[self model] draftCompiler];
        } else {
            settings = [[self model] finalCompiler];
        }
        path = [[CompileFlowHandler path] stringByAppendingPathComponent:[settings compilerPath]];
        
        [task setLaunchPath:path];
        [task setArguments:[NSArray arrayWithObjects:[[self model] texPath], [[self model] pdfPath], [NSString stringWithFormat:@"%@", [settings numberOfCompiles]],
                            [NSString stringWithFormat:@"%@", [settings compileBib]], [NSString stringWithFormat:@"%@", [settings customArgument]], nil]];
        [[NSNotificationCenter defaultCenter] postNotificationName:TMTCompilerDidStartCompiling object:[self model]];
        
        [task setTerminationHandler:^(NSTask *task) {
            if ([NSNotificationCenter defaultCenter]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:TMTCompilerDidEndCompiling object:[self model]];
            }
        }];
        
        [task launch];
}

@end
