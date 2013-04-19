//
//  AppDelegate.m
//  SerializationExample
//
//  Created by Tobias Mende on 19.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "AppDelegate.h"
#import "Person.h"
@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    NSDictionary *p1 = [NSDictionary dictionaryWithObjectsAndKeys:@"Tobias",@"name",[NSNumber numberWithBool:YES], @"male", nil];
    NSDictionary *p2 = [NSDictionary dictionaryWithObjectsAndKeys:@"Lina",@"name",[NSNumber numberWithBool:NO], @"male", nil];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:p1];
    [array addObject:p2];
    [array writeToFile:@"/Users/Tobi/Downloads/test.plist" atomically:YES];
    

    
}

@end
