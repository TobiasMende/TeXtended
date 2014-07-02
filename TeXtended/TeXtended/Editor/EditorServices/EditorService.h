//
//  EditorService.h
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 11.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TMTHelperCollection/NSTextView+TMTExtensions.h>
@class HighlightingTextView;

/**
@author Tobias Mende

 Superclass for additional services for the HighlightingTextView
 */
@interface EditorService : NSObject
    {
        __unsafe_unretained HighlightingTextView *view;
    }

/**
 Method for initializing an EditorService with a HighlightingTextView
 
 @param tv the textview to deal with
 
 @return the EditorService
 */

    - (id)initWithTextView:(HighlightingTextView *)tv;
@end
