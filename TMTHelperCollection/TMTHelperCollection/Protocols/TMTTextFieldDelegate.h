//
//  TMTExtendedTextFieldDelegate.h
//  TMTHelperCollection
//
//  Created by Tobias Mende on 04.05.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TMTTextField;

@protocol TMTTextFieldDelegate <NSTextFieldDelegate>

@optional

- (void) controlDidSelectText:(TMTTextField *)control;

@end
