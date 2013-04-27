//
//  SpellCheckingService.h
//  TeXtended
//
//  Created by Tobias Mende on 26.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "EditorService.h"
@interface SpellCheckingService : EditorService {
    NSMutableSet *commandsToIgnore;
    NSMutableSet *environmentsToIgnore;
    NSMutableSet *wordsToIgnore;
}
- (void) setupSpellChecker;
- (void) addWordToIgnore:(NSString*)string;
- (void) removeWordToIgnore:(NSString*)string;
- (void) updateSpellChecker;
@end
