//
//  OutlineElement.h
//  TeXtended
//
//  Created by Tobias Mende on 02.08.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DocumentModel;

typedef enum LatexLogLevel {
CHAPTER,
    SECTION,
    SUBSECTION,
    INPUT,
    INCLUDE,
    LABEL,
    REF,
    TODO
} TMTLatexLogLevel;

@interface OutlineElement : NSManagedObject

@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * line;
@property (nonatomic, retain) NSString * info;
@property (nonatomic, retain) DocumentModel *document;

+ (NSSet*)extractIn:(NSString *)content for:(DocumentModel*)model;

@end
