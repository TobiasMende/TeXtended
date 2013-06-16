//
//  ForwardSynctex.h
//  TeXtended
//
//  Created by Tobias Mende on 16.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ForwardSynctex : NSObject

- initWithInputPath:(NSString*)inPath outputPath:(NSString *)outPath row:(NSUInteger)row andColumn:(NSUInteger)col;

@property NSUInteger page;
@property CGFloat x;
@property CGFloat y;
@property CGFloat h;
@property CGFloat v;
@property CGFloat width;
@property CGFloat height;
@end
