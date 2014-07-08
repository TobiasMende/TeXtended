//
//  NSRegularExpression+LatexExtensions.h
//  TMTHelperCollection
//
//  Created by Tobias Mende on 03.07.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSRegularExpression (LatexExtensions)
/** Getter for the command regex
 
 @return the regular expression used for detecting commands.
 */
+ (NSRegularExpression *)commandExpression;
@end
