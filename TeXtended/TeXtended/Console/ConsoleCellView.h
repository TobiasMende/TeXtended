//
//  ConsoleCellView.h
//  TeXtended
//
//  Created by Tobias Mende on 03.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class ConsoleData;
@interface ConsoleCellView : NSTableCellView
@property (strong) IBOutlet NSProgressIndicator *progress;
@property (strong, nonatomic) ConsoleData *console;

- (IBAction)remove:(id)sender;
- (NSString *)compilerInfo;
@end
