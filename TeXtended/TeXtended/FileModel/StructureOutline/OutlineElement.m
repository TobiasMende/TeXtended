//
//  OutlineElement.m
//  TeXtended
//
//  Created by Tobias Mende on 02.08.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "OutlineElement.h"
#import "DocumentModel.h"
#import <TMTHelperCollection/TMTLog.h>
#import "TMTNotificationCenter.h"

@interface OutlineElement ()
- (void)subnodeDidChangeNotification:(NSNotification *)note;
@end

@implementation OutlineElement


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.type = [[aDecoder decodeObjectForKey:@"type"] unsignedLongValue];
        self.line = [[aDecoder decodeObjectForKey:@"line"] unsignedIntegerValue];
        self.info = [aDecoder decodeObjectForKey:@"info"];
        self.document = [aDecoder decodeObjectForKey:@"document"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(self.type) forKey:@"type"];
    [aCoder encodeObject:@(self.line) forKey:@"line"];
    [aCoder encodeObject:self.info forKey:@"info"];
    [aCoder encodeObject:self.document forKey:@"document"];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%u - %@(%li) - %@", self.type, self.document.texName, self.line, self.info];
}

- (void)setSubNode:(DocumentModel *)subNode {
    if (_subNode) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:TMTOutlineDidChangeNotification object:_subNode];
    }
    _subNode = subNode;
    if (_subNode) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subnodeDidChangeNotification:) name:TMTOutlineDidChangeNotification object:_subNode];
    }
}

- (void)subnodeDidChangeNotification:(NSNotification *)note {
    NSMutableArray *path = note.userInfo[TMTOutlineChangePath];
    [path addObject:self.document];
    [[NSNotificationCenter defaultCenter] postNotificationName:TMTOutlineDidChangeNotification object:self.document userInfo:@{TMTOutlineChangePath: path}];
}

- (BOOL)isLeaf {
    return (self.subNode == nil);
}

- (NSArray *)children {
    return self.subNode.outlineElements;
}

- (NSUInteger)childCount {
    if ([self isLeaf]) {
        return 0;
    }
    return self.children.count;
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    NSSet *keys = [super keyPathsForValuesAffectingValueForKey:key];
    if ([key isEqualToString:@"children"]) {
        keys = [keys setByAddingObject:@"subNode.outlineElements"];
    } else if([key isEqualToString:@"childCount"]) {
        keys = [keys setByAddingObjectsFromArray:@[@"subNode.outlineElements"]];
    } else if([key isEqualToString:@"isLeaf"]) {
        keys = [keys setByAddingObject:@"subNode"];
    }
    return keys;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


+ (NSString *)localizedNameForType:(OutlineElementType)type {
    switch (type) {
        case CHAPTER:
            return NSLocalizedString(@"Chapter", nil);
        case SECTION:
            return NSLocalizedString(@"Section", nil);
        case SUBSECTION:
            return NSLocalizedString(@"Subsection", nil);
        case INPUT:
            return NSLocalizedString(@"Input", nil);
        case INCLUDE:
            return NSLocalizedString(@"Include", nil);
        case LABEL:
            return NSLocalizedString(@"Label", nil);
        case REF:
            return NSLocalizedString(@"Reference", nil);
        case TODO:
            return NSLocalizedString(@"TODO", nil);
        default:
            return @"";
            break;
    }
}



@end
