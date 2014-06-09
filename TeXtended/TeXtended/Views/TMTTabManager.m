//
//  TMTTabViewWindowManager.m
//  TeXtended
//
//  Created by Tobias Mende on 02.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "TMTTabManager.h"
#import "TMTTabViewController.h"
#import "Constants.h"

static TMTTabManager *tabManager = nil;

@interface TMTTabManager ()

- documentModelIsDeleted:(NSNotification *)note;

@end

@implementation TMTTabManager

    - (id)init
    {
        self = [super init];
        windowSet = [NSMutableSet new];
        tabViewControllers = [NSMutableSet new];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(documentModelIsDeleted:) name:TMTDocumentModelIsDeleted object:nil];
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

- (id)documentModelIsDeleted:(NSNotification *)note {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSTabViewItem *item = [self tabViewItemForIdentifier:note.userInfo[TMTTexIdentifierKey]];
        if (item) {
            [item.tabView removeTabViewItem:item];
             [[NSNotificationCenter defaultCenter] postNotificationName:TMTTabViewDidCloseNotification object:[item.identifier identifier]];
        }
        
        item = [self tabViewItemForIdentifier:note.userInfo[TMTPdfIdentifierKey]];
        if (item) {
            [item.tabView removeTabViewItem:item];
             [[NSNotificationCenter defaultCenter] postNotificationName:TMTTabViewDidCloseNotification object:[item.identifier identifier]];
        }
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
