//
//  TMTLatexTableCellView.h
//  TMTLatexTableFramework
//
//  Created by Tobias Mende on 03.08.14.
//  Copyright (c) 2014 TeXtended. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class TMTLatexTableCellModel;
@interface TMTLatexTableCellView : NSTableCellView
- (TMTLatexTableCellModel *)model;
@end
