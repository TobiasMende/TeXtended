//
//  MessageDataSource.h
//  TeXtended
//
//  Created by Tobias Mende on 23.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DocumentModel, MessageCollection, TrackingMessage, TMTTableView;
@interface MessageDataSource : NSObject <NSTableViewDataSource, NSTableViewDelegate> {
}
@property (weak) IBOutlet TMTTableView *tableView;
@property (weak) MessageCollection *collection;
@property NSArray *messages;
@property (strong,nonatomic) DocumentModel *model;
@end
