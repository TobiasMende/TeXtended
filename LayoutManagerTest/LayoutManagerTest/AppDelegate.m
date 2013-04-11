//
//  AppDelegate.m
//  LayoutManagerTest
//
//  Created by Tobias Mende on 08.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "AppDelegate.h"
@implementation AppDelegate

+ (void)initialize {
    NSUserDefaults *c = [NSUserDefaults standardUserDefaults];
    [c setObject:[NSArchiver archivedDataWithRootObject:[NSColor greenColor]] forKey:MGSFragariaPrefsVariablesColourWell];
    [c setObject:[NSArchiver archivedDataWithRootObject:[NSColor redColor]] forKey:MGSFragariaPrefsStringsColourWell];
    [c setObject:[NSArchiver archivedDataWithRootObject:[NSColor greenColor]] forKey:MGSFragariaPrefsAttributesColourWell];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    // create an instance
	fragaria = [[MGSFragaria alloc] init];
	
	[fragaria setObject:self forKey:MGSFODelegate];
	
        // define our syntax definition
	[self setSyntaxDefinition:@"LaTeX"];
	
        // embed editor in editView
    [fragaria setObject:[NSColor greenColor] forKey:MGSFragariaPrefsCommandsColourWell];
    [fragaria setObject:[NSNumber numberWithBool:YES] forKey:MGSFOIsSyntaxColoured];
    [fragaria setObject:[NSNumber numberWithBool:YES] forKey:MGSFOShowLineNumberGutter];
	[fragaria embedInView:self.editView];
}

/**
 Test
 askldalkdalknasknl
 
 
 adkasdklnasnklaslnkasknldasklndasnlk
 */
- (void)setSyntaxDefinition:(NSString *)name
{
	[fragaria setObject:name forKey:MGSFOSyntaxDefinitionName];
}

/*
 
 - syntaxDefinition
 
 */
- (NSString *)syntaxDefinition
{
	return [fragaria objectForKey:MGSFOSyntaxDefinitionName];
	
}


@end
