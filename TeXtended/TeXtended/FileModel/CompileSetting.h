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

@property (nonatomic, retain) NSString * compilerPath;
@property (nonatomic, retain) NSNumber * compileBib;
@property (nonatomic, retain) NSNumber * numberOfCompiles;
@property (nonatomic, retain) NSString * customArgument;

@end
