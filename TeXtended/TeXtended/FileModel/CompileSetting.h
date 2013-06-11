//
//  CompileSetting.h
//  TeXtended
//
//  Created by Tobias Mende on 08.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CompileSetting : NSManagedObject

@property (nonatomic, strong) NSString * compilerPath;
@property (nonatomic, strong) NSNumber * compileBib;
@property (nonatomic, strong) NSNumber * numberOfCompiles;
@property (nonatomic, strong) NSString * customArgument;


+ (CompileSetting *)defaultLiveCompileSettingIn:(NSManagedObjectContext*)context;
+ (CompileSetting *)defaultDraftCompileSettingIn:(NSManagedObjectContext*)context;
+ (CompileSetting *)defaultFinalCompileSettingIn:(NSManagedObjectContext*)context;
- (void) unbindAll;

- (CompileSetting *)copy:(NSManagedObjectContext*)context;
- (void) binAllTo:(CompileSetting *)setting;

- (BOOL) containsSameValuesAs:(CompileSetting *)other;
@end
