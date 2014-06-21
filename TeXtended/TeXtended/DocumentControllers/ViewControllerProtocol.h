//
//  ViewControllerProtocol.h
//  TeXtended
//
//  Created by Tobias Mende on 22.09.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FirstResponderDelegate.h"

@protocol ViewControllerProtocol <NSObject>


@optional
    - (id)initWithFirstResponder:(id <FirstResponderDelegate>)dc;

    - (void)breakUndoCoalescing;

    - (NSTabViewItem *)tabViewItem;

@end
