//
//  MessageOutlineViewController.h
//  TeXtended
//
//  Created by Tobias Mende on 26.10.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Compilable, MessageDataSource;
@interface MessageOutlineViewController : NSViewController
@property (assign) Compilable* model;
@property (assign)  IBOutlet MessageDataSource *messageDataSource;


- (id)initWithModel:(Compilable*)model;
@end
