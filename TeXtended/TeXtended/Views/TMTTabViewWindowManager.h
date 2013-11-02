//
//  TMTTabViewWindowManager.h
//  TeXtended
//
//  Created by Tobias Mende on 02.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TMTTabViewWindow;

@interface TMTTabViewWindowManager : NSObject {
    NSMutableSet *windowSet;
    
}

+ (TMTTabViewWindowManager *) sharedTabViewWindowManager;

- (void) addTabViewWindow:(TMTTabViewWindow *)window;
- (void) removeTabViewWindow:(TMTTabViewWindow *)window;
@end
