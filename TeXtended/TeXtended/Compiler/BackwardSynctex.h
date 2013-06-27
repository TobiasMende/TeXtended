//
//  BackwardSynctex.h
//  TeXtended
//
//  Created by Tobias Mende on 26.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BackwardSynctex : NSObject
- initWithOutputPath:(NSString *)outPath page:(NSUInteger)page andPosition:(NSPoint) position;

/** The line in the input document */
@property NSUInteger line;

/** The column in the input document */
@property NSUInteger column;

/** The input document for the given position */
@property NSString *inputPath;

@property NSInteger offset;

@property NSString *context;
@end
