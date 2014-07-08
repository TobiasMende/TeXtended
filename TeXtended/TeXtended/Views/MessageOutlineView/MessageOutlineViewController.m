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

@interface MessageOutlineViewController ()

@end

@implementation MessageOutlineViewController


    - (id)initWithModel:(DocumentModel *)model
    {
        self = [self initWithNibName:@"MessageOutlineView" bundle:nil];
        if (self) {
            self.model = model;

        }
        return self;
    }

    - (void)loadView
    {
        [super loadView];
        [self.messageDataSource setModel:self.model];
    }

@end
