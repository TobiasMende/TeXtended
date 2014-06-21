//
//  TemplatesCollectionView.m
//  TeXtended
//
//  Created by Tobias Mende on 18.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "TemplatesCollectionView.h"
#import "TemplatePlaceholderController.h"
#import "Template.h"

@implementation TemplatesCollectionView

    - (NSCollectionViewItem *)newItemForRepresentedObject:(id)object
    {
        if (![object isKindOfClass:[Template class]]) {
            NSCollectionViewItem *other = [[NSCollectionViewItem alloc] initWithNibName:@"AddTemplatePlaceholder" bundle:nil];
            return other;
        } else {
            NSCollectionViewItem *item = [TemplatePlaceholderController new];
            item.representedObject = object;
            return item;
        }
    }

@end
