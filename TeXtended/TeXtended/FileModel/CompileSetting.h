//
//  CompileSetting.h
//  TeXtended
//
//  Created by Tobias Mende on 08.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Instances of this class represent the core data object CompileSetting which is used to store the compiler configuration for a project oder document model.
 *
 * **Author:** Tobias Mende
 *
 */

@interface CompileSetting : NSObject <NSCoding>

/** The path to the compile flow */
@property (nonatomic, strong) NSString *compilerPath;

/** Flag whether to compile bibliography or not */
@property (nonatomic, strong) NSNumber *compileBib;

/** the number of compiler iterations */
@property (nonatomic, strong) NSNumber *numberOfCompiles;

/** some custom argument set by the user */
@property (nonatomic, strong) NSString *customArgument;


/** Getter for a default live compile setting generated using the user defaults
 *
 * @param context The context to insert the new object into
 *
 * return a new compile setting object
 */
+ (CompileSetting *)defaultLiveCompileSetting;

/** Getter for a default draft compile setting generated using the user defaults
 *
 * @param context The context to insert the new object into
 *
 * return a new compile setting object
 */
+ (CompileSetting *)defaultDraftCompileSetting;

/** Getter for a default final compile setting generated using the user defaults
 *
 * @param context The context to insert the new object into
 *
 * return a new compile setting object
 */
+ (CompileSetting *)defaultFinalCompileSetting;

/** Method for unbinding all properties of this object */
- (void)unbindAll;


/**
 * Method for binding all properties to another setting object.
 *
 * This method is usefull when handling the symbiosis between ProjectModel and DocumentModel.
 *
 * @param setting the settings to bind to
 */
- (void)bindAllTo:(CompileSetting *)setting;

@end
