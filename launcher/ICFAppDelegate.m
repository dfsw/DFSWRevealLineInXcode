//
//  ICFAppDelegate.m
//  launcher
//
//  Created by Kyle Richter on 5/18/13.
//  Copyright (c) 2013 Kyle Richter. All rights reserved.
//

#import "ICFAppDelegate.h"  
#import "DFSWRevealLineInXcode.h"

@implementation ICFAppDelegate

- (void)dealloc
{
    [super dealloc];
}

- (IBAction)go:(id)sender
{
    
    BOOL openProject = NO;
    
    if([self.openProjectFile state] == NSOnState)
        openProject = YES;
    
    [DFSWRevealLineInXcode openFileInXcode:self.filepathTextField.stringValue atLine:[self.lineNumberTextField.stringValue intValue] launchProject:openProject];
}

@end
