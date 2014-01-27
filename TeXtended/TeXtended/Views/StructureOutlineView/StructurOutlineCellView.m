//
//  StructurOutlineCellView.m
//  TeXtended
//
//  Created by Tobias Mende on 26.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "StructurOutlineCellView.h"
#import "OutlineElement.h"
#import "Constants.h"
#import "DocumentModel.h"
#import "NSColor+TMTExtension.h"
#import "CacheManager.h"
static NSMutableDictionary *COLOR_LOOKUP;
static NSMutableDictionary *IMAGE_LOOKUP;
@interface StructurOutlineCellView ()
@end
@implementation StructurOutlineCellView

+ (void)initialize {
    if ([self class] == [StructurOutlineCellView class]) {
        COLOR_LOOKUP = [NSMutableDictionary new];
        IMAGE_LOOKUP = [NSMutableDictionary new];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSLog(@"init");
    }
    return self;
}


- (OutlineElement *)element {
    return [self objectValue];
}

- (void)setObjectValue:(id)objectValue {
    if (super.objectValue) {
        [self unbind:@"textColor"];
    }
    super.objectValue = objectValue;
}


- (NSColor *)textColor {
    return [[CacheManager sharedCacheManager] colorForOutlineElement:self.element];
}

- (NSImage *)image {
    return [[CacheManager sharedCacheManager] imageForOutlineElement:self.element];
}





- (NSString *)toolTip {
    return [NSString stringWithFormat:@"%@: %@ (%@ [%li])", [OutlineElement localizedNameForType:self.element.type],self.element.info, self.element.document.texName, self.element.line];
}




+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    NSSet *keys = [super keyPathsForValuesAffectingValueForKey:key];
    if ([key isEqualToString:@"image"]) {
        keys = [keys setByAddingObjectsFromArray:@[@"objectValue.type",@"textColor"]];
    } else if([key isEqualToString:@"toolTip"]) {
        keys = [keys setByAddingObjectsFromArray:@[@"element.info", @"element.document.texName", @"element.line", @"element.type"]];
    } else if([key isEqualToString:@"element"]) {
        keys = [keys setByAddingObject:@"objectValue"];
    } else if([key isEqualToString:@"textColor"]) {
        keys = [keys setByAddingObjectsFromArray:@[@"element.type"]];
    }
    return keys;
}


- (void)dealloc {
    NSLog(@"Dealloc");
}
@end
