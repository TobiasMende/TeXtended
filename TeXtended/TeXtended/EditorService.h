//
//  EditorService.h
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 11.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HighlightingTextView;
@interface EditorService : NSObject {
    HighlightingTextView* view;
}

- (id)initWithTextView:(HighlightingTextView*) tv;
@end
