//
//  NSTextView+LatexExtensions.h
//  TMTHelperCollection
//
//  Created by Tobias Mende on 02.07.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSTextView (LatexExtensions)
/**
 Method for detecting whether the insertion is final or not depending on the text movement type
 
 @param movement the text movement
 
 @return `YES` if the insertion is final, `NO` otherwise.
 
 */
- (BOOL)isFinalInsertion:(NSUInteger)movement;
@end
