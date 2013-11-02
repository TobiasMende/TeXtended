//
//  DemoFakeModel.m
//  TeXtended
//
//  Created by Max Bannach on 26.10.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "TMTTabViewItem.h"

@implementation TMTTabViewItem

@synthesize title            = _title;
@synthesize largeImage       = _largeImage;
@synthesize icon             = _icon;
@synthesize iconName         = _iconName;
@synthesize isProcessing     = _isProcessing;
@synthesize objectCount      = _objectCount;
@synthesize objectCountColor = _objectCountColor;
@synthesize showObjectCount  = _showObjectCount;
@synthesize isEdited         = _isEdited;
@synthesize hasCloseButton   = _hasCloseButton;
@synthesize view             = view;

- (id)init {
	if (self = [super init]) {
		_isProcessing     = NO;
		_icon             = nil;
		_iconName         = nil;
        _largeImage       = nil;
		_objectCount      = 0;
		_isEdited         = NO;
        _hasCloseButton   = YES;
        _title            = @"TeXtended!";
        _objectCountColor = nil;
        _showObjectCount  = NO;
        _view             = nil;
	}
	return self;
}


@end