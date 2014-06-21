//
//  BibDocument.h
//  TeXtended
//
//  Created by Tobias Mende on 15.03.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class HighlightingTextView;

@interface BibDocument : NSDocument
    {
        NSString *tmpContent;
    }

    @property (strong) IBOutlet NSScrollView *scrollView;

    @property (strong) IBOutlet HighlightingTextView *contentView;

    @property NSStringEncoding encoding;

    - (IBAction)openInBibdesk:(id)sender;

    - (BOOL)bibdeskAvailable;

@end
