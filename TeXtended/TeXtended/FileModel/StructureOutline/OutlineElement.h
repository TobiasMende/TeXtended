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

@interface OutlineElement : NSObject <NSCoding>

@property OutlineElementType type;
@property NSUInteger line;
@property (strong) NSString * info;
@property (assign) DocumentModel *document;
@property (strong,nonatomic) DocumentModel *subNode;

- (BOOL)isLeaf;
- (NSArray *)children;
- (NSUInteger)childCount;

+ (NSString *)localizedNameForType:(OutlineElementType)type;

@end
