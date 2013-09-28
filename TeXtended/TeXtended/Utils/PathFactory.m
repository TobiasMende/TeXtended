//
//  PathFactory.m
//  TeXtended
//
//  Created by Tobias Mende on 16.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "PathFactory.h"
#import "Constants.h"
#import "TMTLog.h"

static NSString *TEMP_EXTENSION = @"TMTTemporaryStorage";
@implementation PathFactory


+ (NSString *)texbin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults valueForKey:TMT_PATH_TO_TEXBIN];
}


+ (NSString *)texdoc {
    return [[self texbin] stringByAppendingPathComponent:@"texdoc"];
}

+ (NSString *)synctex {
    return [[self texbin] stringByAppendingPathComponent:@"synctex"];
}

+ (NSString *)lacheck {
    return [[self texbin] stringByAppendingPathComponent:@"lacheck"];
}

+ (NSString *)chktex {
    return [[self texbin] stringByAppendingPathComponent:@"chktex"];
}




+ (BOOL)checkForAndCreateFolder:(NSString *)path {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    BOOL isDirectory = NO;
    BOOL exists = [fm fileExistsAtPath:path isDirectory:&isDirectory];
    if (exists && isDirectory) {
        return YES;
    } else if(exists && !isDirectory) {
        DDLogWarn(@"Path exists but isn't a directory!: %@", path);
        return NO;
    }else {
        [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (!error) {
            return  YES;
        } else {
            DDLogError(@"Can't create directory %@. Error: %@", path, [error userInfo]);
            return NO;
        }
    }
}

+ (NSString *)pathToTemporaryStorage:(NSString *)path {
    return [path stringByAppendingPathExtension:TEMP_EXTENSION];
}

+ (NSString *)realPathFromTemporaryStorage:(NSString *)temp {
    if ([[temp pathExtension] isEqualToString:TEMP_EXTENSION]) {
        return [temp stringByDeletingPathExtension];
    }
    return  temp;
}

+(NSString *)absolutPathFor:(NSString *)path withBasedir:(NSString *)dir {
    if ([path isAbsolutePath]) {
        return path;
    }
    return [dir stringByAppendingPathComponent:path];
}

@end
