//
//  CompileSetting.m
//  TeXtended
//
//  Created by Tobias Mende on 08.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "CompileSetting.h"
#import "Constants.h"
#import "TMTLog.h"

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
    [setting bind:@"compilerPath" toObject:defaults withKeyPath:path options:nil];
    [setting bind:@"compileBib" toObject:defaults withKeyPath:bib options:nil];
    [setting bind:@"numberOfCompiles" toObject:defaults withKeyPath:iteration options:nil];
    [setting bind:@"customArgument" toObject:defaults withKeyPath:args options:nil];
    return setting;
}

- (void)unbindAll {
    [self unbind:@"compilerPath"];
    [self unbind:@"compileBib"];
    [self unbind:@"numberOfCompiles"];
    [self unbind:@"customArgument"];
}

- (void)willTurnIntoFault {
    [self unbindAll];
    [super willTurnIntoFault];
}

- (CompileSetting *)copy:(NSManagedObjectContext *)context {
    CompileSetting *setting = [NSEntityDescription
                               insertNewObjectForEntityForName:@"CompileSetting"
                               inManagedObjectContext:context];
    setting.compilerPath = self.compilerPath;
    setting.compileBib = self.compileBib;
    setting.numberOfCompiles = self.numberOfCompiles;
    setting.customArgument = self.customArgument;
    return setting;
}

- (void)binAllTo:(CompileSetting *)setting {
    [self bind:@"compilerPath" toObject:setting withKeyPath:@"compilerPath" options:nil];
    [self bind:@"compileBib" toObject:setting withKeyPath:@"compileBib" options:nil];
    [self bind:@"numberOfCompiles" toObject:setting withKeyPath:@"numberOfCompiles" options:nil];
    [self bind:@"customArgument" toObject:setting withKeyPath:@"customArgument" options:nil];
}

- (BOOL)containsSameValuesAs:(CompileSetting *)other {
    if (![self.compilerPath isEqualToString:other.compilerPath]) {
        return NO;
    }
    if (![self.compileBib isEqualToNumber:other.compileBib]) {
        return NO;
    }
    if (![self.numberOfCompiles isEqualToNumber:other.numberOfCompiles]) {
        return NO;
    }
    if (![self.customArgument isEqualToString:other.customArgument]) {
        return NO;
    }
    return YES;
}

- (void) initDefaults {
    DDLogError(@"NOOOOO");
}
@end
