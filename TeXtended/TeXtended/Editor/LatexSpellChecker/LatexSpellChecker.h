//
//  LatexSpellChecker.h
//  TeXtended
//
//  Created by Tobias Mende on 08.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LatexSpellChecker : NSSpellChecker
    {
        NSArray *prefixesToIgnore;
    }

@end
