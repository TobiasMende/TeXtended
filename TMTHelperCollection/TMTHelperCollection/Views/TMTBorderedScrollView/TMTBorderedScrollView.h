//
//  TMTBorderedScrollView.h
//  TMTHelperCollection
//
//  Created by Tobias Mende on 22.10.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TMTBorderedScrollView : NSScrollView

@property BOOL leftBorder;
@property BOOL rightBorder;
@property BOOL bottomBorder;
@property BOOL topBorder;

@end
