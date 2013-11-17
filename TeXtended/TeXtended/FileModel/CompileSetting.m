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
+ (CompileSetting*) createCompileSettingFor:(NSString*) path bibKey:(NSString*)bib iterationKey:(NSString*)iteration argsKey:(NSString*)args;
@end

@implementation CompileSetting

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.compilerPath = [aDecoder decodeObjectForKey:@"compilerPath"];
        self.compileBib = [aDecoder decodeObjectForKey:@"compileBib"];
        self.numberOfCompiles = [aDecoder decodeObjectForKey:@"numberOfCompiles"];
        self.customArgument = [aDecoder decodeObjectForKey:@"customArgument"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.compilerPath forKey:@"compilerPath"];
    [aCoder encodeObject:self.compileBib forKey:@"compileBib"];
    [aCoder encodeObject:self.numberOfCompiles forKey:@"numberOfCompiles"];
    [aCoder encodeObject:self.customArgument forKey:@"customArgument"];
}



+ (CompileSetting *)defaultDraftCompileSetting {
        return [self createCompileSettingFor:TMTDraftCompileFlow bibKey:TMTDraftCompileBib iterationKey:TMTDraftCompileIterations argsKey:TMTDraftCompileArgs];
}

+ (CompileSetting *)defaultLiveCompileSetting {
        return [self createCompileSettingFor:TMTLiveCompileFlow bibKey:TMTLiveCompileBib iterationKey:TMTLiveCompileIterations argsKey:TMTLiveCompileArgs];
}

+ (CompileSetting *)defaultFinalCompileSetting {
        
        return [self createCompileSettingFor:TMTFinalCompileFlow bibKey:TMTFinalCompileBib iterationKey:TMTFinalCompileIterations argsKey:TMTFinalCompileArgs];
}

+ (CompileSetting *)createCompileSettingFor:(NSString *)path bibKey:(NSString *)bib iterationKey:(NSString *)iteration argsKey:(NSString *)args{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CompileSetting *setting = [CompileSetting new];
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

- (void)dealloc {
    [self unbindAll];
}

- (id)copy {
    CompileSetting *setting = [CompileSetting new];
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
