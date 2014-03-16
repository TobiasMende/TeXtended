//
//  MessageDataSource.h
//  TeXtended
//
//  Created by Tobias Mende on 23.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DocumentModel, TrackingMessage, TMTTableView, MessageInfoViewController;
@interface MessageDataSource : NSObject <NSTableViewDataSource, NSTableViewDelegate> {
    MessageInfoViewController *infoController;
    NSPopover *popover;
    NSLock *messageLock;
}
@property (strong) IBOutlet TMTTableView *tableView;
@property NSArray *messages;
@property (strong,nonatomic) DocumentModel *model;
@end
