//
//  CompletionsController.h
//  TeXtended
//
//  Created by Tobias Mende on 22.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 The CompletionsController handles loading and saving of auto completions and the displaying and editing of them in the preferences window.

 For a better performance when completing, completions are stored in a NSMutableDictionary. Therefor a NSMutableArray is used to sync the dictionary with the table view. This provides a sorted view.
 
 **Author:** Tobias Mende
 
 
 @warning *Important:* Due to the fact that this class deals with files in the application support folder. There can't be more than one instance of the CompletionsController. To ensure this fact, it's designed as singleton. Therefor calling [CompletionsController init] doesn't create a new instance if one exists.
 */
@interface CompletionsController : NSObject <NSTableViewDataSource> {
    /** The keys for command completions */
    NSMutableArray *commandKeys;
    
    /** The keys for environment completions */
    NSMutableArray *environmentKeys;
}

/** The environment completion view */
@property (weak) IBOutlet NSTableView *environmentView;

/** The command completion view */
@property (weak) IBOutlet NSTableView *commandsView;

/** The command completions
 @see CommandCompletion
 */
@property (strong) NSMutableDictionary *commandCompletions;

/** The environment completions 
 @see EnironmentCompletion
 */
@property (strong) NSMutableDictionary *environmentCompletions;

/** Indexes of the selected rows in the command view */
@property  (strong) NSIndexSet *selectedCommandIndexes;

/** Indexes of selected rows in the environment view */
@property  (strong) NSIndexSet *selectedEnvironmentIndexes;

/** Removes the selected item of the appropriate table view 
 @param sender the button identified by tag
 */
- (IBAction)removeItem:(id)sender;

/** Adds an item to the appropriate table view 
 @param sender the button identified by tag
 */
- (IBAction)addItem:(id)sender;

/** Resets the environment completions to the set of completions provided with the application bundle 
  @param sender the button identified by tag
 */
- (IBAction)resetEnvironmentCompletions:(id)sender;

/** Resets the command completions to the set of completions provided with the application bundle 
  @param sender the button identified by tag
 */
- (IBAction)resetCommandCompletions:(id)sender;

/** Stores completions to the disk using the applications support folder if possible */
- (void) saveCompletions;
@end
