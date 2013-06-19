//
//  TextViewObserver.h
//  TeXtended
//
//  Created by Tobias Mende on 16.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 The TextViewObserver protocol is used to mark objects that need to listen to NSTextViewDelegate methods called on a TextViewController.
 
 Further methods might be added if neccesary.
 
 **Author:** Tobias Mende
 
 */
@protocol TextViewObserver <NSTextViewDelegate>

@end
