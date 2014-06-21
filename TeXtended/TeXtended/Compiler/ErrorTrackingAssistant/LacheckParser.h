//
//  LacheckParser.h
//  TeXtended
//
//  Created by Tobias Mende on 18.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Parser.h"


@class DocumentModel;

/**
 * Implementation of a parser which parses the output of the lacheck command, generating warnings about missing brackets, $ and $$.
 *
 * **Author:** Tobias Mende
 *
 */

@interface LacheckParser : Parser
    {
    }
@end
