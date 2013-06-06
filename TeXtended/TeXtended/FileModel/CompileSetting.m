//
//  CompileSetting.m
//  TeXtended
//
//  Created by Tobias Mende on 08.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "CompileSetting.h"
#import "Constants.h"

@interface CompileSetting ()
+ (CompileSetting*) createCompileSettingFor:(NSString*) path bibKey:(NSString*)bib iterationKey:(NSString*)iteration argsKey:(NSString*)args andContext:(NSManagedObjectContext*) context;
@end

@implementation CompileSetting

@dynamic compilerPath;
@dynamic compileBib;
@dynamic numberOfCompiles;
@dynamic customArgument;

+ (CompileSetting *)defaultDraftCompileSettingIn:(NSManagedObjectContext*)context {
    return [self createCompileSettingFor:TMTDraftCompileFlow bibKey:TMTDraftCompileBib iterationKey:TMTDraftCompileIterations argsKey:TMTDraftCompileArgs andContext:context];
    
}

+ (CompileSetting *)defaultLiveCompileSettingIn:(NSManagedObjectContext*)context {
    return [self createCompileSettingFor:TMTLiveCompileFlow bibKey:TMTLiveCompileBib iterationKey:TMTLiveCompileIterations argsKey:TMTLiveCompileArgs andContext:context];
}

+ (CompileSetting *)defaultFinalCompileSettingIn:(NSManagedObjectContext*)context {
    return [self createCompileSettingFor:TMTFinalCompileFlow bibKey:TMTFinalCompileBib iterationKey:TMTFinalCompileIterations argsKey:TMTFinalCompileArgs andContext:context];
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
    return setting;
}


@end
