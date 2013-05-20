//
//  DFSWRevealLineInXcode.m
//
//  Created by Kyle Richter on 5/20/13.
//  Copyright (c) 2013 Kyle Richter. All rights reserved.
//
/*
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 The views and conclusions contained in the software and documentation are those
 of the authors and should not be interpreted as representing official policies,
 either expressed or implied, of the FreeBSD Project.
 */

#import "DFSWRevealLineInXcode.h"

@implementation DFSWRevealLineInXcode


+(void)openAtLine:(int)line
{    
    NSRunningApplication *app = [[NSRunningApplication runningApplicationsWithBundleIdentifier: @"com.apple.dt.Xcode"] objectAtIndex:0];
    
    while(!app.isFinishedLaunching && !app.ownsMenuBar)
    {
        nanosleep((struct timespec[]){{0, 100000000}}, NULL); //pause .1 seconds
        app = [[NSRunningApplication runningApplicationsWithBundleIdentifier: @"com.apple.dt.Xcode"] objectAtIndex:0];
    }
    
    ProcessSerialNumber psn;
    
    GetProcessForPID([app processIdentifier], &psn);
        
    int translatedKeyCode = keyCodeForChar('l');
    CGEventRef lKey = CGEventCreateKeyboardEvent (NULL, (CGKeyCode)translatedKeyCode, true);
    NSMutableArray *lineNumberKeys = [[[NSMutableArray alloc] init] autorelease];
    
    NSString *lineNumberString = [NSString stringWithFormat:@"%i", line];
    
    for(int x = 0; x < lineNumberString.length; x++)
    {
        NSString *digit = [lineNumberString substringWithRange:NSMakeRange(x, 1)];
        
        int lineDigit = 0;
        
        switch ([digit intValue])
        {
            case 0:
                lineDigit = 29;
                break;
            case 1:
                lineDigit = 18;
                break;
            case 2:
                lineDigit = 19;
                break;
            case 3:
                lineDigit = 20;
                break;
            case 4:
                lineDigit = 21;
                break;
            case 5:
                lineDigit = 23;
                break;
            case 6:
                lineDigit = 22;
                break;
            case 7:
                lineDigit = 26;
                break;
            case 8:
                lineDigit = 28;
                break;
            case 9:
                lineDigit = 25;
                break;
            default:
                break;
        }
        
        [lineNumberKeys addObject: [NSNumber numberWithInt:lineDigit]];
    }
    
    CGEventRef returnKey = CGEventCreateKeyboardEvent (NULL, (CGKeyCode)36, true);
    
    sleep(1);
    
    CGEventSetFlags(lKey, kCGEventFlagMaskCommand);
    CGEventPostToPSN (&psn,lKey);
    nanosleep((struct timespec[]){{0, 500000000}}, NULL); 
    
    
    for(NSNumber *digitNum in lineNumberKeys)
    {
        CGEventRef digitEvent = CGEventCreateKeyboardEvent (NULL, (CGKeyCode)[digitNum intValue], true);
        CGEventPostToPSN (&psn,digitEvent);
        nanosleep((struct timespec[]){{0, 100000000}}, NULL);
    }
    
    sleep(1);
    
    CGEventPostToPSN (&psn,returnKey);
}

+(void)openFileInXcode:(NSString*)filePath atLine:(int)line launchProject:(BOOL)launchProject
{
    NSString *rootProjectPath = nil;
    
    if(launchProject)
    {
        
        NSString *oneBack = [filePath stringByDeletingLastPathComponent];
        NSError *error = nil;
        
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:oneBack error:&error];
        
        if(error != nil)
        {
            launchProject = NO;
        }
        
        else
        {
            while(rootProjectPath == nil && error == nil && launchProject)
            {
                for(NSString *file in files)
                {                    
                    if([file hasSuffix:@".xcodeproj"])
                    {
                        rootProjectPath = [oneBack stringByAppendingPathComponent:file ];
                        break;
                    }
                }
                
                if([oneBack isEqualToString:[oneBack stringByDeletingLastPathComponent]])
                {
                    launchProject = NO;
                    break;
                    
                }
                
                oneBack = [oneBack stringByDeletingLastPathComponent];
                files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:oneBack error:&error];
            }
        }
    }    
    
    BOOL isXcodeRunning = NO;
    
    for(NSRunningApplication *app in (NSArray *)[[NSWorkspace sharedWorkspace] runningApplications])
    {
        if([[app localizedName] isEqualToString:@"Xcode"])
        {
            isXcodeRunning = YES;
        }
    }
    
    if(!isXcodeRunning)
    {
        [[NSWorkspace sharedWorkspace] launchApplication: @"Xcode"];
        
        NSString *path = filePath;
        
        NSString *theSource = [NSString stringWithFormat:@"tell application \"Xcode\" to open \"%@\"\n", path];
        
        NSAppleScript *theScript = [[NSAppleScript alloc] initWithSource:theSource];
        
        NSDictionary *errorDict = nil;
        
        if(launchProject && rootProjectPath)
        {
            NSString *rootSource = [NSString stringWithFormat:@"tell application \"Xcode\" to open \"%@\"\n", rootProjectPath];
            NSAppleScript *rootScript = [[NSAppleScript alloc] initWithSource:rootSource];
            NSDictionary *rootErrorDict = nil;

            if([rootScript executeAndReturnError:&rootErrorDict])
            {
                nanosleep((struct timespec[]){{0, 500000000}}, NULL); //pause .1 seconds
                [[NSWorkspace sharedWorkspace] openFile:filePath withApplication:@"Xcode"];
                nanosleep((struct timespec[]){{0, 500000000}}, NULL); //pause .1 seconds
                [self openAtLine: line];
            }
            
            else
            {
                NSLog(@"Error Opening Source Project File: %@ source: %@", rootErrorDict, rootSource);
            }
        }
        
        else if([theScript executeAndReturnError:&errorDict])
        {
            [self openAtLine: line];
        }
        
        else
        {
            NSLog(@"Error Opening File: %@ source: %@", errorDict, theSource);
        }
    }
    
    else
    {
         if(launchProject && rootProjectPath)
         {
             [[NSWorkspace sharedWorkspace] openFile:rootProjectPath withApplication:@"Xcode"];
             sleep(3); //hopefully enough time for Xcode to fully load
         }
        
        [[NSWorkspace sharedWorkspace] openFile:filePath withApplication:@"Xcode"];
        [self openAtLine: line];
    }
}

CFStringRef createStringForKey(CGKeyCode keyCode)
{
    TISInputSourceRef currentKeyboard = TISCopyCurrentKeyboardInputSource();
    CFDataRef layoutData =
    TISGetInputSourceProperty(currentKeyboard,
                              kTISPropertyUnicodeKeyLayoutData);
    const UCKeyboardLayout *keyboardLayout =
    (const UCKeyboardLayout *)CFDataGetBytePtr(layoutData);
    
    UInt32 keysDown = 0;
    UniChar chars[4];
    UniCharCount realLength;
    
    UCKeyTranslate(keyboardLayout,
                   keyCode,
                   kUCKeyActionDisplay,
                   0,
                   LMGetKbdType(),
                   kUCKeyTranslateNoDeadKeysBit,
                   &keysDown,
                   sizeof(chars) / sizeof(chars[0]),
                   &realLength,
                   chars);
    CFRelease(currentKeyboard);
    
    return CFStringCreateWithCharacters(kCFAllocatorDefault, chars, 1);
}

int keyCodeForChar(const char c)
{
    static CFMutableDictionaryRef charToCodeDict = NULL;
    int code;
    UniChar character = c;
    CFStringRef charStr = NULL;
    
    if (charToCodeDict == NULL) {
        size_t i;
        charToCodeDict = CFDictionaryCreateMutable(kCFAllocatorDefault,
                                                   128,
                                                   &kCFCopyStringDictionaryKeyCallBacks,
                                                   NULL);
        if (charToCodeDict == NULL) return UINT16_MAX;
        
        for (i = 0; i < 128; ++i) {
            CFStringRef string = createStringForKey((CGKeyCode)i);
            if (string != NULL) {
                CFDictionaryAddValue(charToCodeDict, string, (const void *)i);
                CFRelease(string);
            }
        }
    }
    
    charStr = CFStringCreateWithCharacters(kCFAllocatorDefault, &character, 1);
    
    if (!CFDictionaryGetValueIfPresent(charToCodeDict, charStr,
                                       (const void **)&code)) {
        code = UINT16_MAX;
    }
    
    CFRelease(charStr);
    return code;
}

@end
