//
//  CiteCompletion.h
//  TeXtended
//
//  Created by Tobias Mende on 18.12.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CompletionProtocol.h"

@class TMTBibTexEntry;

@interface CiteCompletion : NSObject <CompletionProtocol>

    @property TMTBibTexEntry *entry;

    - (id)initWithBibEntry:(TMTBibTexEntry *)entry;

    - (NSComparisonResult)compare:(CiteCompletion *)other;
@end
