//
//  FIleOutlineTextField.m
//  TeXtended
//
//  Created by Tobias Mende on 04.05.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "TMTTextField.h"
#import "TMTLog.h"
#import "TMTTextFieldDelegate.h"
@implementation TMTTextField

- (void)selectText:(id)sender {
    [super selectText:sender];
    if (self.delegate && [self.delegate respondsToSelector:@selector(controlDidSelectText:)]) {
        [(id<TMTTextFieldDelegate>)self.delegate controlDidSelectText:self];
    }
}

@end
