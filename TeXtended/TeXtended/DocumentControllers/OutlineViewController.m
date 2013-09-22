//
//  OutlineViewController.m
//  TeXtended
//
//  Created by Tobias Mende on 26.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "OutlineViewController.h"

@interface OutlineViewController ()

@end

@implementation OutlineViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initialize];
    }
    
    return self;
}


- (void) initialize {
    //TODO: add children view depending on current model
}


- (NSSet*)children {
    return [NSSet setWithObject:nil];
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"OutlineViewController dealloc");
#endif
}

@end
