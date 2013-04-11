//
//  SimpleHighlightingView.h
//  LayoutManagerTest
//
//  Created by Tobias Mende on 08.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SimpleHighlightingView : NSTextView {
    NSRange currentLineRange;
}

@end
