//
//  SpellCheckingService.m
//  TeXtended
//
//  Created by Tobias Mende on 26.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "SpellCheckingService.h"
#import "HighlightingTextView.h"
#import "CompletionsController.h"
#import "CommandCompletion.h"
#import "EnvironmentCompletion.h"
#import "Constants.h"

static const NSUInteger SECONDS_BETWEEEN_UPDATES = 5;

@interface SpellCheckingService()

- (void) setupEnvironmentsToIgnore;
- (void) setupCommandsToIgnore;
- (void) updateEnvironmentsToIgnore;
- (void) updateCommandsToIgnore;
@end

@implementation SpellCheckingService

- (id)initWithTextView:(HighlightingTextView *)tv {
    self = [super initWithTextView:tv];
    if (self) {
        commandsToIgnore = [[NSMutableSet alloc] init];
        environmentsToIgnore = [[NSMutableSet alloc] init];
        wordsToIgnore = [[NSMutableSet alloc] init];
        [self setupSpellChecker];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCommandsToIgnore) name:TMTCommandCompletionsDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateEnvironmentsToIgnore) name:TMTEnvironmentCompletionsDidChangeNotification object:nil];
        backgroundQueue = [NSOperationQueue new];
    }
    return self;
}


- (void)setupEnvironmentsToIgnore {
    CompletionsController *cc = [[CompletionsController alloc] init];
    NSArray *completions = [[cc environmentCompletions] allValues];
    for (EnvironmentCompletion *c in completions) {
        [environmentsToIgnore addObject:c.insertion];
    }
}

- (void)setupCommandsToIgnore {
    CompletionsController *cc = [[CompletionsController alloc] init];
    NSArray *completions = [[cc commandCompletions] allValues];
    for (CommandCompletion *c in completions) {
        if ([[c.insertion substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"\\"]) {
            NSString *completion = [c.insertion substringFromIndex:1];
            [commandsToIgnore addObject:completion];
        }
    }
}

-(void)updateCommandsToIgnore {
    [commandsToIgnore removeAllObjects];
    [self setupCommandsToIgnore];
    [self updateSpellChecker];
}

- (void)updateEnvironmentsToIgnore {
    [environmentsToIgnore removeAllObjects];
    [self setupEnvironmentsToIgnore];
    [self updateSpellChecker];
}

- (void)addWordToIgnore:(NSString *)string {
     [wordsToIgnore addObject:string];
}

- (void)removeWordToIgnore:(NSString *)string {
    [wordsToIgnore removeObject:string];
}

- (void)setupSpellChecker {
    // NSLog(@"%@", ignore);
    [self setupEnvironmentsToIgnore];
    [self setupCommandsToIgnore];
    [self updateSpellChecker];
    
}

- (void)updateSpellChecker {
    //NSLog(@"Updating Spell Checker: \tC:%ld \tE:%ld \tW:%ld", commandsToIgnore.count, environmentsToIgnore.count, wordsToIgnore.count);
    if (lastUpdated && -[lastUpdated timeIntervalSinceNow] < SECONDS_BETWEEEN_UPDATES) {
        return;
    }
    lastUpdated = [[NSDate alloc] init];
    [backgroundQueue addOperationWithBlock:^{
        NSMutableSet *allWords = [[NSMutableSet alloc] initWithSet:wordsToIgnore];
        [allWords unionSet:environmentsToIgnore];
        [allWords unionSet:commandsToIgnore];
        [[NSSpellChecker sharedSpellChecker] setIgnoredWords:[allWords allObjects] inSpellDocumentWithTag:view.spellCheckerDocumentTag];
    }];
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"SpellCheckingService dealloc");
#endif
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
