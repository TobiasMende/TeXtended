//
//  MessageOutlineViewController.m
//  TeXtended
//
//  Created by Tobias Mende on 26.10.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "MessageOutlineViewController.h"
#import "Compilable.h"
#import "MessageDataSource.h"
#import "TMTLog.h"

@interface MessageOutlineViewController ()

@end

@implementation MessageOutlineViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}


- (id)initWithModel:(Compilable*)model {
    self = [self initWithNibName:@"MessageOutlineView" bundle:nil];
    if (self) {
        self.model = model;
        
    }
    return self;
}

-(void)loadView {
    [super loadView];
    [self.messageDataSource setModel:self.model];
}

@end
