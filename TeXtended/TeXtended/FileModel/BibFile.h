//
//  BibFile.h
//  TeXtended
//
//  Created by Tobias Mende on 01.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ProjectModel;

@interface BibFile : NSManagedObject

@property (nonatomic, retain) NSDate * lastRead;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) ProjectModel *project;

@end
