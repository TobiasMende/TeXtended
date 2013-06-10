//
//  CompileSetting.m
//  TeXtended
//
//  Created by Tobias Mende on 08.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "CompileSetting.h"
#import "Constants.h"

static CompileSetting *defaultDraftCompiler;
static CompileSetting *defaultFinalCompiler;
static CompileSetting *defaultLiveCompiler;
@interface CompileSetting ()
+ (CompileSetting*) createCompileSettingFor:(NSString*) path bibKey:(NSString*)bib iterationKey:(NSString*)iteration argsKey:(NSString*)args andContext:(NSManagedObjectContext*) context;
@end

@implementation CompileSetting

@dynamic compilerPath;
@dynamic compileBib;
@dynamic numberOfCompiles;
@dynamic customArgument;

+ (CompileSetting *)defaultDraftCompileSettingIn:(NSManagedObjectContext*)context {
    if (!defaultDraftCompiler) {
        defaultDraftCompiler = [self createCompileSettingFor:TMTDraftCompileFlow bibKey:TMTDraftCompileBib iterationKey:TMTDraftCompileIterations argsKey:TMTDraftCompileArgs andContext:context];
    }
    return defaultDraftCompiler;
}

+ (CompileSetting *)defaultLiveCompileSettingIn:(NSManagedObjectContext*)context {
    if(!defaultLiveCompiler) {
        defaultLiveCompiler =  [self createCompileSettingFor:TMTLiveCompileFlow bibKey:TMTLiveCompileBib iterationKey:TMTLiveCompileIterations argsKey:TMTLiveCompileArgs andContext:context];
    }
    return defaultLiveCompiler;
}

+ (CompileSetting *)defaultFinalCompileSettingIn:(NSManagedObjectContext*)context {
    if(!defaultFinalCompiler) {
        
        defaultFinalCompiler = [self createCompileSettingFor:TMTFinalCompileFlow bibKey:TMTFinalCompileBib iterationKey:TMTFinalCompileIterations argsKey:TMTFinalCompileArgs andContext:context];
    }
    return defaultFinalCompiler;
}

+ (CompileSetting *)createCompileSettingFor:(NSString *)path bibKey:(NSString *)bib iterationKey:(NSString *)iteration argsKey:(NSString *)args andContext:(NSManagedObjectContext*) context{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CompileSetting *setting = [NSEntityDescription
                               insertNewObjectForEntityForName:@"CompileSetting"
                               inManagedObjectContext:context];
    setting.compilerPath = [defaults stringForKey:path];
    setting.compileBib = [defaults objectForKey:bib];
    setting.numberOfCompiles = [defaults objectForKey:iteration];
    setting.customArgument = [defaults stringForKey:args];
    [setting bind:@"compilerPath" toObject:defaults withKeyPath:path options:nil];
    [setting bind:@"compileBib" toObject:defaults withKeyPath:bib options:nil];
    [setting bind:@"numberOfCompiles" toObject:defaults withKeyPath:iteration options:nil];
    [setting bind:@"customArgument" toObject:defaults withKeyPath:args options:nil];
    return setting;
}


- (void)willTurnIntoFault {
    [self unbind:@"compilerPath"];
    [self unbind:@"compileBib"];
    [self unbind:@"numberOfCompiles"];
    [self unbind:@"customArgument"];
    [super willTurnIntoFault];
}

@end
