//
//  DemoFakeModel.m
//  TeXtended
//
//  Created by Max Bannach on 26.10.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "TMTTabViewItem.h"
#import <TMTHelperCollection/TMTLog.h>

@implementation TMTTabViewItem


- (id)init {
	if (self = [super init]) {
		self.isProcessing     = NO;
		self.icon             = nil;
		self.iconName         = nil;
        self.largeImage       = nil;
		self.objectCount      = 0;
		self.isEdited         = NO;
        self.hasCloseButton   = YES;
        self.title            = @"TeXtended!";
        self.objectCountColor = nil;
        self.showObjectCount  = NO;
        self.view             = nil;
	}
	return self;
}


@end