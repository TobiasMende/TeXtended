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

- (IBAction)remove:(id)sender;
- (NSString *)compilerInfo;
@property (weak) ConsoleData *console;
@end
