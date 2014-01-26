//
//  NSString+TMTExtension.h
//  TeXtended
//
//  Created by Tobias Mende on 26.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (TMTExtension)
- (NSArray *)lineRanges;
- (NSUInteger)lineNumberForRange:(NSRange)range;
@end
