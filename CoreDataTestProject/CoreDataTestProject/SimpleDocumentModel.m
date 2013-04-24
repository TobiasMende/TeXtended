//
//  SimpleDocumentModel.m
//  CoreDataTestProject
//
//  Created by Tobias Mende on 23.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "SimpleDocumentModel.h"

@implementation SimpleDocumentModel

- (id)init {
    NSLog(@"Init");
    return [super init];
}

- (id)initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context {
    NSLog(@"Init with entity");
    return [super initWithEntity:entity insertIntoManagedObjectContext:context];
}

- (void) bla {
    self.entity.compileSettings;
}
@end
