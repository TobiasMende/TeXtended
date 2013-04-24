//
//  TexdocViewController.h
//  TeXtended
//
//  Created by Tobias Mende on 23.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TexdocViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>{
    IBOutlet NSMutableArray *entries;
    IBOutlet NSTableView *listView;
    IBOutlet NSView *notFoundView;
}
@property (strong, nonatomic) NSString *package;
- (void) setContent:(NSMutableArray*) texdoc;
@end
