//
//  TMTTabViewWindowManager.m
//  TeXtended
//
//  Created by Tobias Mende on 02.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "TMTTabManager.h"
#import "TMTTabViewController.h"

static TMTTabManager *tabManager = nil;

@implementation TMTTabManager

    - (id)init
    {
        self = [super init];
        windowSet = [NSMutableSet new];
        tabViewControllers = [NSMutableSet new];

        return self;
    }

    + (TMTTabManager *)sharedTabManager
    {
        if (!tabManager) {
            tabManager = [TMTTabManager new];
        }
        return tabManager;
    }


    - (void)addTabViewWindow:(TMTTabViewWindow *)window
    {
        [windowSet addObject:window];
    }

    - (void)removeTabViewWindow:(TMTTabViewWindow *)window
    {
        [windowSet removeObject:window];
    }


    - (void)addTabViewController:(TMTTabViewController *)controller
    {
        [tabViewControllers addObject:[NSValue valueWithNonretainedObject:controller]];
    }

    - (void)removeTabViewController:(TMTTabViewController *)controller
    {
        [tabViewControllers removeObject:[NSValue valueWithNonretainedObject:controller]];
    }

    - (NSTabViewItem *)tabViewItemForIdentifier:(NSString *)identifier
    {
        for (NSValue *v in tabViewControllers) {
            TMTTabViewController *controller = v.nonretainedObjectValue;
            if (controller) {
                for (NSTabViewItem *item in controller.tabView.tabViewItems) {
                    if ([[item.identifier identifier] isEqualToString:identifier]) {
                        return item;
                    }
                }
            }
        }
        return nil;
    }

@end
