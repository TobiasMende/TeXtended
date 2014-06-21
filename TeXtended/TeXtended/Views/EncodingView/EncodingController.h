//
//  EncodingController.h
//  TeXtended
//
//  Created by Tobias Hecht on 21.09.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EncodingController : NSViewController <NSOpenSavePanelDelegate>
    {
    }

    @property IBOutlet NSPopUpButton *popUp;

    @property NSArray *encodings;

    @property BOOL selectionDidChange;

    - (NSStringEncoding)selection;
@end
