//
//  Compilable.h
//  TeXtended
//
//  Created by Tobias Mende on 01.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Compilable : NSManagedObject

@property (nonatomic, retain) NSString * draftCompiler;
@property (nonatomic, retain) NSString * finalCompiler;
@property (nonatomic, retain) NSString * liveCompiler;

- (id) initWithContext:(NSManagedObjectContext*)context;
@end
