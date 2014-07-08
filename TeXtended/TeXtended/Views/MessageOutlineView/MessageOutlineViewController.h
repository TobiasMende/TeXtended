//
//  MessageOutlineViewController.h
//  TeXtended
//
//  Created by Tobias Mende on 26.10.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DocumentModel, MessageDataSource;

@interface MessageOutlineViewController : NSViewController

    @property (assign) DocumentModel *model;

    @property (assign) IBOutlet MessageDataSource *messageDataSource;


    - (id)initWithModel:(DocumentModel *)model;
@end
