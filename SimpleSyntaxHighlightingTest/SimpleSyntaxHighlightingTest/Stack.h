//
//  Stack.h
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 09.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Stack : NSObject {
    NSMutableArray *container;
}
- (void) push:(id) obj;
- (id) pop;
- (BOOL) isEmpty;
- (id) last;

@end
