//
//  TMTLatexTableView.h
//  TMTLatexTable
//
//  Created by Tobias Mende on 03.08.14.
//  Copyright (c) 2014 TeXtended. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TMTLatexTableView : NSTableView

@property SEL cmdArrowUpAction;
@property SEL cmdArrowDownAction;
@property SEL cmdArrowLeftAction;
@property SEL cmdArrowRightAction;

@property SEL altArrowUpAction;
@property SEL altArrowDownAction;
@property SEL altArrowLeftAction;
@property SEL altArrowRightAction;

- (void)addTableColumnAtIndex:(NSUInteger)index;
- (void)removeTableColumnAtIndex:(NSUInteger)index;
@end
