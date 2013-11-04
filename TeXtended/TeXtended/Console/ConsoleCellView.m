//
//  ConsoleCellView.m
//  TeXtended
//
//  Created by Tobias Mende on 03.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "ConsoleCellView.h"
#import "Constants.h"
#import "ConsoleData.h"
#import "CompileSetting.h"
#import "DocumentModel.h"

@interface ConsoleCellView ()
@end

@implementation ConsoleCellView



- (void)setConsole:(ConsoleData *)console {
    if (console != _console) {
        if (_console) {
            [_console removeObserver:self forKeyPath:@"self.consoleActive"];
        }
        _console = console;
        if (_console) {
            [_console addObserver:self forKeyPath:@"self.consoleActive" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isEqualTo:self.console]) {
        if (self.console.consoleActive) {
            [self.progress performSelectorOnMainThread:@selector(startAnimation:) withObject:nil waitUntilDone:NO];
        } else {
            [self.progress performSelectorOnMainThread:@selector(stopAnimation:) withObject:nil waitUntilDone:NO];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


- (NSString *)compilerInfo {
    NSString *type;
    CompileSetting *setting = nil;
    switch (self.console.compileMode) {
        case live:
            type = NSLocalizedString(@"Live", @"Live");
            setting = self.console.model.liveCompiler;
            break;
        case draft:
            type = NSLocalizedString(@"Draft", @"Draft");
            setting = self.console.model.draftCompiler;
            break;
        case final:
            type = NSLocalizedString(@"Final", @"Final");
            setting = self.console.model.finalCompiler;
            break;
        default:
            type = NSLocalizedString(@"Unknown", @"Unknown");
            break;
    }
    return [NSString stringWithFormat:@"%@ | %@ |%ldx", type, setting.compilerPath.lastPathComponent,setting.numberOfCompiles.unsignedIntegerValue];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    NSSet *set = [super keyPathsForValuesAffectingValueForKey:key];
    if ([key isEqualToString:@"compilerInfo"]) {
        set = [set setByAddingObjectsFromSet:[NSSet setWithObjects:@"self.console.compileMode",@"self.console.model", @"self.console.model.liveCompiler.compilerPath",@"self.console.model.draftCompiler.compilerPath",@"self.console.model.finalCompiler.compilerPath",@"self.console.model.liveCompiler.numberOfCompiles",@"self.console.model.draftCompiler.numberOfCompiles",@"self.console.model.finalCompiler.numberOfCompiles",nil]];
    }
    return set;
}


- (void)remove:(id)sender {
    self.console.showConsole = NO;
}

- (void)dealloc {
    self.console = nil;
}
@end
