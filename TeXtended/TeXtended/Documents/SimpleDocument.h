//
//  SimpleDocument.h
//  TeXtended
//
//  Created by Tobias Mende on 17.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LineNumberView.h"

@interface SimpleDocument : NSDocument {
    /** Extention of NSRulerView to show line numbers. */
    LineNumberView *lineNumberView;
}
@property (weak) IBOutlet NSScrollView *scrollView;

@end
