//
//  DocumentSelectionAccessoryController.m
//  TeXtended
//
//  Created by Tobias Mende on 09.10.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "DocumentSelectionAccessoryController.h"

@interface DocumentSelectionAccessoryController ()

@end

@implementation DocumentSelectionAccessoryController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}


- (NSArray *)localizedSummaryItems {
    return @[@{NSPrintPanelAccessorySummaryItemNameKey: self.documentSelector.selectedItem.value, NSPrintPanelAccessorySummaryItemDescriptionKey: @"The document name"}];
}


+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    if ([key isEqualToString:@"localizedSummaryItems"]) {
        NSArray *array = @[@"self.documentSelector.selectedItem"];
        keyPaths = [keyPaths setByAddingObjectsFromArray:array];
    }
    return keyPaths;
}



@end
