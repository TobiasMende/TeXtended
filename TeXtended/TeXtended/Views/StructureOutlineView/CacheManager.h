//
//  CacheManager.h
//  TeXtended
//
//  Created by Tobias Mende on 27.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
@class OutlineElement;
@interface CacheManager : NSObject {
    NSMutableDictionary *COLOR_LOOKUP;
    NSMutableDictionary *IMAGE_LOOKUP;
}
- (NSImage *)imageForOutlineElement:(OutlineElement *)element;
- (NSColor *)colorForOutlineElement:(OutlineElement *)element;

+ (CacheManager *)sharedCacheManager;
@end
