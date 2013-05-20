//
//  ICFAppDelegate.h
//  launcher
//
//  Created by Kyle Richter on 5/18/13.
//  Copyright (c) 2013 Kyle Richter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ICFAppDelegate : NSObject <NSApplicationDelegate>
@property (assign) IBOutlet NSTextField *filepathTextField;
@property (assign) IBOutlet NSTextField *lineNumberTextField;
@property (assign) IBOutlet NSButton *openProjectFile;
@property (assign) IBOutlet NSWindow *window;
- (IBAction)go:(id)sender;

@end
