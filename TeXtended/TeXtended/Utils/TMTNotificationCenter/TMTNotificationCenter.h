//
//  TMTNotificationCenter.h
//  TeXtended
//
//  Created by Tobias Mende on 26.10.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Compilable;

@interface TMTNotificationCenter : NSNotificationCenter


    + (NSNotificationCenter *)centerForCompilable:(Compilable *)compilable;

    + (void)removeCenterForCompilable:(Compilable *)compilable;
@end
