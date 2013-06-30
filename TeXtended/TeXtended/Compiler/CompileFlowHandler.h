//
//  CompileFlowHandler.h
//  TeXtended
//
//  Created by Tobias Mende on 01.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * The compile flow handler is a singleton design for getting a list of all compile flows in the application support directory.
 *
 * **Author:** Tobias Mende
 *
 */
@interface CompileFlowHandler : NSArrayController {
}

/**
 * Getter for the shared instance of this singleton.
 *
 * @return the one and only instance
 */
+ (CompileFlowHandler*)sharedInstance;

/**
 * Getter for an array of compile flows.
 *
 * @return an array of flows
 */
- (NSArray *)flows;

/**
 * Returns the path to the CompileFlows-Directory in the application support folder.
 *
 * @return the absolut path
 */
+ (NSString *)path;

/** This number might be used in the user interface to limit the number of iterations (upper border) */
@property (readonly) NSNumber *maxIterations;

/** This number might be used in the user interface to limit the number of iterations (lower border) */
@property (readonly) NSNumber *minIterations;

@end
