//
//  DropCompletion.h
//  TeXtended
//
//  Created by Tobias Hecht on 05.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "Completion.h"

@interface DropCompletion : Completion

@property BOOL usePathExtentsion;
-(NSAttributedString*)getCompletion:(NSString*)path;

@end
