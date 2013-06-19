//
//  CompileSetting.h
//  TeXtended
//
//  Created by Tobias Mende on 08.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/**
 Instances of this class represent the core data object CompileSetting which is used to store the compiler configuration for a project oder document model.
 
 **Author:** Tobias Mende
 
 */

@interface CompileSetting : NSManagedObject

/** The path to the compile flow */
@property (nonatomic, strong) NSString * compilerPath;

/** Flag whether to compile bibliography or not */
@property (nonatomic, strong) NSNumber * compileBib;

/** the number of compiler iterations */
@property (nonatomic, strong) NSNumber * numberOfCompiles;

/** some custom argument set by the user */
@property (nonatomic, strong) NSString * customArgument;


/** Getter for a default live compile setting generated using the user defaults
 
 @param context The context to insert the new object into
 
 return a new compile setting object
 */
+ (CompileSetting *)defaultLiveCompileSettingIn:(NSManagedObjectContext*)context;

/** Getter for a default draft compile setting generated using the user defaults
 
 @param context The context to insert the new object into
 
 return a new compile setting object
 */
+ (CompileSetting *)defaultDraftCompileSettingIn:(NSManagedObjectContext*)context;

/** Getter for a default final compile setting generated using the user defaults
 
 @param context The context to insert the new object into
 
 return a new compile setting object
 */
+ (CompileSetting *)defaultFinalCompileSettingIn:(NSManagedObjectContext*)context;

/** Method for unbinding all properties of this object */
- (void) unbindAll;

/**
 Method for getting a copy of the current CompileSetting object in another or the same context
 
 @param context The context for the copy
 
 @return an identical setting object in the given context
 */
- (CompileSetting *)copy:(NSManagedObjectContext*)context;

/**
 Method for binding all properties to another setting object.
 
 This method is usefull when handling the symbiosis between ProjectModel and DocumentModel.
 
 @param setting the settings to bind to
 */
- (void) binAllTo:(CompileSetting *)setting;

/**
 Method for checking equality of the properties
 
 @param other the other setting object to check against
 
 @return `YES` if all properties are equal, `NO` otherwise.
 */
- (BOOL) containsSameValuesAs:(CompileSetting *)other;
@end
