//
//  CompileFlowHandler.h
//  TeXtended
//
//  Created by Tobias Mende on 01.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CompileFlowHandler : NSArrayController {
}
+ (CompileFlowHandler*)sharedInstance;

- (NSArray *)flows;
/**
 Returns the path to the CompileFlows-Directory in the application support folder.
 
 
 @return the absolut path
 */
+ (NSString *)path;

@property (readonly) NSNumber *maxIterations;
@property (readonly) NSNumber *minIterations;
@end
