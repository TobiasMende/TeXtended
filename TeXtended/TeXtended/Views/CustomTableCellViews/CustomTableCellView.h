//
//  CustomTableCellView.h
//  TeXtended
//
//  Created by Tobias Mende on 19.12.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CustomTableCellView <NSObject>

    + (NSInteger)defaultViewHeight;

    @property id objectValue;
@end
