//
//  ModelInfoViewController.h
//  TeXtended
//
//  Created by Tobias Mende on 17.05.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Compilable.h"
@protocol ModelInfoViewController <NSObject>
    - (void)setModel:(Compilable *)model;

@end
