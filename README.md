DFSWRevealLineInXcode
=====================

This source code is licensed under BSD. 

This code can be used to launch Xcode to a specific line number of Xcode from a Mac OS X app. 

Additionally it can force the opening of the owning project file before opening the source code. Xcode itself does not provide any service hooks for accomplishing these task and AppleScript is far too slow and buggy to accomplish this task. There are several known concerns with this project namely around running on slower machines and sleep() to ensure everything is properly launched. Disabling the option for launching a project when opening the source will be much less prone to error. I make no guarantees or assurances that this code will work in all situations. While this approach isn't super fast it is considerably faster and more stable than AppleScript especially when going to a line in a file that is already open.

Usage:

Add carbon.framework to your project
Add DFSWRevealLineInXcode.h and DFSWRevealLineInXcode.h

#import "DFSWRevealLineInXcode.h"

-(void)myMethod
{
	[DFSWRevealLineInXcode openFileInXcode:(NSString *)projectPath atLine:(int)1 launchProject:(BOOL)openPorjectFirst];
}