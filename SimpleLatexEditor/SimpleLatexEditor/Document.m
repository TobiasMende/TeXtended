//
//  Document.m
//  SimpleLatexEditor
//
//  Created by Tobias Mende on 03.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "Document.h"
#import "LatexDocument.h"
#import "PreviewController.h"
#import "DockableView.h"
@implementation Document
- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        _latex = [[LatexDocument alloc] init];
        _canCompile = YES;
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
    lineNumberView = [[MarkerLineNumberView alloc] initWithScrollView:self.scrollView];
    [self.scrollView setVerticalRulerView:lineNumberView];
    [self.scrollView setHasHorizontalRuler:NO];
    [self.scrollView setHasVerticalRuler:YES];
    [self.scrollView setRulersVisible:YES];
    [self.editorView setFont:[NSFont userFixedPitchFontOfSize:[NSFont smallSystemFontSize]]];
    NSLog(@"WC did load nib");
    
    
	
    [self.editorView setFont:[NSFont userFixedPitchFontOfSize:[NSFont smallSystemFontSize]]];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    
    if ([typeName isEqualToString:@"LatexType"]) {
        NSLog(@"Data of type");
        return [[self.latex content] dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    @throw exception;
    return nil;
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    NSLog(@"Reading document from url ...");
    if([typeName isEqualToString:@"LatexType"]) {
        [self.latex setPath:url];
        return [super readFromURL:url ofType:typeName error:outError];
        
    }
    return NO;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
    NSLog(@"Reading document from data ...");
    if([typeName isEqualToString:@"LatexType"]) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:NSPlainTextDocumentType,NSDocumentTypeDocumentAttribute, nil];
        NSError *error;
        NSDictionary *attrb;
        NSAttributedString *attrbString = [[NSAttributedString alloc] initWithData:data options:dict documentAttributes:&attrb error:&error];
        if(error != NULL) {
            NSLog(@"Error while reading latex document");
            return NO;
        }
        if(attrbString != nil) {
            [self.latex setContent:[attrbString string]];
            return YES;
        }
    }
    return NO;
}

- (IBAction)showPreviewWindow:(id)sender {
    if(!previewController) {
       previewController = [[PreviewController alloc] initWithWindowNibName:@"PreviewWindow"];
        [previewController setLatex:self.latex];
    }
    [previewController showWindow:self];
    
}

-(void)saveDocument:(id)sender {
    [super saveDocument:sender];
    self.latex.path = [self fileURL];
}

- (IBAction)compile:(id)sender {
    if (!self.canCompile) {
        return;
    }
    NSArray *currentSelection = [self.editorView selectedRanges];
    [self saveDocument:self];
    [self.editorView setSelectedRanges:currentSelection];
    [self.editorWindow makeFirstResponder:self.editorView];
    if(self.latex.path != nil) {
        
        NSTask *compileTask = [[NSTask alloc] init];
        [compileTask setLaunchPath:@"/usr/texbin/lualatex"];
        NSString *outputDir = [NSString stringWithFormat:@"-output-directory=%@", [self.latex directoryPath]];
        NSLog(@"%@",outputDir);
        NSLog(@"Path String: %@",[self.latex.path absoluteString]);
        NSArray *arguments = [NSArray arrayWithObjects:@"-shell-escape", outputDir, [self.latex.path path], nil];
        
        [compileTask setArguments:arguments];
       void (^terminationHandler)(NSTask*) = ^(NSTask *task) {
           NSLog(@"Task finished");
           [self performSelectorOnMainThread:@selector(showPDF:) withObject:self waitUntilDone:YES];
           [self setCanCompile:YES];
        };
        [compileTask setTerminationHandler:terminationHandler];
        [self setCanCompile:NO];
        [compileTask launch];
        
        NSLog(@"Task launched");
        
    } else {
        NSLog(@"No path set. Please save first!");
    }
    
}

- (void)textDidChange:(NSNotification *)notification {
    if(self.canCompile && self.autoCompile) {
        [self compile:self];
    }
}


- (IBAction)showPDF:(id)sender {
    NSArray *currentSelection = [self.editorView selectedRanges];
    [self showPreviewWindow:self];
    [self.editorView setSelectedRanges:currentSelection];
    [self.editorWindow makeKeyAndOrderFront:self];
    [previewController updateView:self];
    [self.editorWindow makeFirstResponder:self.editorView];
}
@end
