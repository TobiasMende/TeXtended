//
//  OutlineHelper.h
//  TeXtended
//
//  Created by Tobias Mende on 15.03.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OutlineHelper : NSObject

    + (NSMutableArray *)flatten:(NSArray *)currentLevel withPath:(NSMutableSet *)path;
@end
