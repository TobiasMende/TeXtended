//
//  Document.m
//  TestProject
//
//  Created by Tobias Mende on 28.03.13.
//
//

#import "Document.h"
#import "PreferencesController.h"
#import "NSUserDefaults+DefaultsColorSupport.h"

@implementation Document
@synthesize firstTextView;
- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here;
        content = [[NSString alloc] init];
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"Document";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    NSDictionary *option = [NSDictionary dictionaryWithObjectsAndKeys:NSUnarchiveFromDataTransformerName,NSValueTransformerNameBindingOption, nil];
    [firstTextView bind:@"textColor" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:@"values.textColor" options:option];
    [firstTextView bind:@"backgroundColor" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:@"values.backgroundColor" options:option];
    [firstTextView setString:content];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}


+ (BOOL)autosavesInPlace
{
    return YES;
}


# pragma mark Saving and Loading
- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    NSLog(@"Type Name is %@",typeName);
     NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:NSPlainTextDocumentType,NSDocumentTypeDocumentAttribute, nil];
    NSAttributedString *attrbStr = [[NSAttributedString alloc] initWithString:[[firstTextView textStorage] string] attributes:dict];
    if ([typeName isEqualToString:@"TestProjectType"]) {
        NSLog(@"Saving as own type");
    } else if([typeName isEqualToString:@"Tex Documents"]) {
       NSLog(@"Saving as tex type");
   
    } else{
        NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
        @throw exception;
        return nil;
    }
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    
    return [[attrbStr string] dataUsingEncoding:NSUTF8StringEncoding];
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          NSPlainTextDocumentType,
                          NSDocumentTypeDocumentAttribute,
                          nil];
    NSDictionary *attr;
    NSError *error = nil;
    NSAttributedString * attrbString = nil;
    
    NSLog(@"Type Name when opening is %@", typeName);
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
    if ([typeName isEqualToString:@"TestProjectType"]) {
        content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        attrbString = [[NSAttributedString alloc]initWithData:data
                                        options:dict
                             documentAttributes:&attr
                                          error:&error];
        
    } else if([typeName isEqualToString:@"Tex Documents"]) {
        attrbString = [[NSAttributedString alloc]initWithData:data
                                                      options:dict
                                           documentAttributes:&attr
                                                        error:&error];
        
                
    }
    
    if ( error != NULL ) {
        NSLog(@"Error readFromData: %@",[error localizedDescription]);
        return NO;
    } // end if
    if(attrbString != nil) {
        content = [attrbString string];
        return YES;
    }
    

    
    return NO;
}



#pragma mark Default Behaviour

@end
