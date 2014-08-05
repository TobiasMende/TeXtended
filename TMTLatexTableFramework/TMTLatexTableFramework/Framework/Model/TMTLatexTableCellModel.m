//
//  TMTLatexTableCellModel.m
//  TMTLatexTable
//
//  Created by Tobias Mende on 03.08.14.
//  Copyright (c) 2014 TeXtended. All rights reserved.
//

#import "TMTLatexTableCellModel.h"

@implementation TMTLatexTableCellModel

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@", self.content, self.backgroundColor];
}

- (void)setContent:(NSString *)content {
    _content = content;
}
@end
