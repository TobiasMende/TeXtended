//
//  TMTTableViewDelegate.h
//  TMTHelperCollection
//
//  Created by Tobias Mende on 02.07.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMTTableView.h"
@protocol TMTTableViewDelegate <NSTableViewDelegate>

@optional

- (BOOL)tableView:(TMTTableView *)tableView editColumn:(NSInteger)column row:(NSInteger)row withEvent:(NSEvent *)theEvent select:(BOOL)select;
@end
