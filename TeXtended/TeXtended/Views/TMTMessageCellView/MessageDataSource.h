//
//  MessageDataSource.h
//  TeXtended
//
//  Created by Tobias Mende on 23.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Compilable, MessageCollection, TrackingMessage, TMTTableView, MessageInfoViewController;
@interface MessageDataSource : NSObject <NSTableViewDataSource, NSTableViewDelegate> {
    MessageInfoViewController *infoController;
    NSPopover *popover;
    NSLock *messageLock;
}
@property (weak) IBOutlet TMTTableView *tableView;
@property (strong) NSMutableDictionary *collections;
@property NSArray *messages;
@property (weak,nonatomic) Compilable *model;
@end
