//
//  Compilable.h
//  TeXtended
//
//  Created by Tobias Mende on 01.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CompileSetting;
@interface Compilable : NSManagedObject

@property (nonatomic, retain) CompileSetting * draftCompiler;
@property (nonatomic, retain) CompileSetting * finalCompiler;
@property (nonatomic, retain) CompileSetting * liveCompiler;

- (id) initWithContext:(NSManagedObjectContext*)context;
@end
