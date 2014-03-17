//
//  CacheManager.m
//  TeXtended
//
//  Created by Tobias Mende on 27.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "CacheManager.h"
#import "OutlineElement.h"
#import "NSColor+TMTExtension.h"
#import "Constants.h"

static const NSString *OUTLINE_COLOR_CONTEXT = @"OUTLINE_COLOR_CONTEXT";
static const NSArray *OUTLINE_COLOR_KEYS;;
@implementation CacheManager

+ (void)initialize {
    if ([self class] == [CacheManager class]) {
        OUTLINE_COLOR_KEYS = @[TMT_INLINE_MATH_COLOR, TMT_COMMAND_COLOR, TMT_COMMENT_COLOR, TMT_TEXDOC_LINK_COLOR];
    }
}

- (id)init {
    self = [super init];
    if (self) {
        COLOR_LOOKUP = [NSMutableDictionary new];
        IMAGE_LOOKUP = [NSMutableDictionary new];
        
        for (NSString *key in OUTLINE_COLOR_KEYS) {
            [[NSUserDefaultsController sharedUserDefaultsController] addObserver:self forKeyPath:[@"values." stringByAppendingString:key] options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:(__bridge void *)(OUTLINE_COLOR_CONTEXT)];
        }
    }
    return self;
}

+ (CacheManager *) sharedCacheManager {
    static dispatch_once_t pred;
    static CacheManager *cacheManager = nil;
    
    dispatch_once(&pred, ^{
        cacheManager = [[CacheManager alloc] init];
    });
    return cacheManager;
}

- (NSImage *)imageForOutlineElement:(OutlineElement *)element {
    NSImage *image = IMAGE_LOOKUP[@(element.type)];
    if (!image) {
        switch (element.type) {
            case TODO:
                image = [NSImage imageNamed:@"hammer"];
                
                break;
            case SECTION:
            case SUBSECTION:
                image = [NSImage imageNamed:@"arrow-right-c"];
                break;
            case CHAPTER:
                image = [NSImage imageNamed:@"bookmark"];
                image.backgroundColor = [self colorForOutlineElement:element];
                break;
            case REF:
            case LABEL:
                image = [NSImage imageNamed:@"link"];
                break;
            case INCLUDE:
            case INPUT:
                image = [NSImage imageNamed:@"forward"];
                break;
                
            default:
                return nil;
                break;
        }
        NSImage *newImage = [image copy];
        [newImage lockFocus];
        [[self colorForOutlineElement:element] set];
        NSRect imageRect = {NSZeroPoint, [image size]};
        NSRectFillUsingOperation(imageRect, NSCompositeSourceAtop);
        [newImage unlockFocus];
        image = newImage;
        IMAGE_LOOKUP[@(element.type)] = image;
    }
    return image;
}

- (NSColor *)colorForOutlineElement:(OutlineElement *)element {
    if (!element) {
        return nil;
    }
    NSColor *color = COLOR_LOOKUP[@(element.type)];
    
    if (!color) {
        NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
        switch (element.type) {
            case TODO:
                color = [NSUnarchiver unarchiveObjectWithData:[[defaults values] valueForKey:TMT_COMMENT_COLOR]];
                break;
            case SECTION:
                color = [NSUnarchiver unarchiveObjectWithData:[[defaults values] valueForKey:TMT_COMMAND_COLOR]];
                break;
            case SUBSECTION:
                color = [NSUnarchiver unarchiveObjectWithData:[[defaults values] valueForKey:TMT_COMMAND_COLOR]];
                color = [color slightlyLighterColor];
                break;
            case CHAPTER:
                color = [NSUnarchiver unarchiveObjectWithData:[[defaults values] valueForKey:TMT_COMMAND_COLOR]];
                color = [color slightlyDarkerColor];
                break;
            case REF:
            case INCLUDE:
            case INPUT:
                color = [NSUnarchiver unarchiveObjectWithData:[[defaults values] valueForKey:TMT_TEXDOC_LINK_COLOR]];
                break;
            case LABEL:
                color = [NSUnarchiver unarchiveObjectWithData:[[defaults values] valueForKey:TMT_INLINE_MATH_COLOR]];
                break;
            default:
                color = [NSColor blackColor];
                break;
        }
        COLOR_LOOKUP[@(element.type)] = color;
        
    }
    return color;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([OUTLINE_COLOR_CONTEXT isEqualTo:(__bridge id)(context)]) {
        COLOR_LOOKUP = [NSMutableDictionary new];
        IMAGE_LOOKUP = [NSMutableDictionary new];
    }
}

- (void)dealloc {
    for (NSString *key in OUTLINE_COLOR_KEYS) {
        [[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self forKeyPath:[@"values." stringByAppendingString:key]];
    }
}
@end
