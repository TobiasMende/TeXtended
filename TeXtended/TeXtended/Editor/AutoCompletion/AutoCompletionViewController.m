//
//  AutoCompletionViewController.m
//  TeXtended
//
//  Created by Tobias Mende on 23.07.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "AutoCompletionViewController.h"

@interface AutoCompletionViewController ()

@end

@implementation AutoCompletionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)init {
    return [self initWithNibName:@"AutoCompletionView" bundle:nil];
}

- (void)setContent:(NSArray *)content {
    _content = content;
    [self.tableView reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.content.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return [self.content objectAtIndex:row];
}

@end
