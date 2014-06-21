//
//  CommandCompletion.h
//  TeXtended
//
//  Created by Tobias Mende on 18.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "Completion.h"

#define CommandTypeNormal @"normal"
#define CommandTypeCite @"cite"
#define CommandTypeLabel @"label"
#define CommandTypeRef @"ref"

/**
 Class for \command completions. Just needed for identification of the completion type. May provide custom functionality later.
 
 @author Tobias Mende
 */
@interface CommandCompletion : Completion

/** The type of this completion (e.g. normal, cite, label or ref) */
    @property (strong, nonatomic) NSString *completionType;

@end
