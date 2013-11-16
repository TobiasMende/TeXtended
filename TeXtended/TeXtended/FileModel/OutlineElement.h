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

typedef enum OutlineElementType {
    CHAPTER = 4201,
    SECTION = 4202,
    SUBSECTION = 4203,
    INPUT = 4204,
    INCLUDE = 4205,
    LABEL = 4206,
    REF = 4207,
    TODO = 4208
} OutlineElementType;

@interface OutlineElement : NSObject

@property (strong) NSNumber * type;
@property (strong) NSNumber * line;
@property (strong) NSString * info;
@property (strong) DocumentModel *document;

+ (NSSet*)extractIn:(NSString *)content for:(DocumentModel*)model;

+ (NSRegularExpression *)regexForElementType:(OutlineElementType)type;

+ (NSString *)stringForType:(OutlineElementType)type;

@end
