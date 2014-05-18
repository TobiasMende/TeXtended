//
//  TMTLogFormatter.h
//  TeXtended
//
//  Created by Tobias Mende on 28.09.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDLog.h"

@interface TMTLogFormatter : NSObject <DDLogFormatter>

    @property BOOL extended;

    - (id)initExtended:(BOOL)isExtended;

    + (void)updateMaxLength:(NSUInteger)length;

    + (NSString *)extendClassPart:(NSString *)classPart;

@end
