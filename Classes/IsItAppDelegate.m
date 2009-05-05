//
//  IsItAppDelegate.m
//  IsIt
//
//  Created by Shawn Roske on 5/4/09.
//  Copyright Bitgun 2009. All rights reserved.
//

#import "IsItAppDelegate.h"
#import "IsItViewController.h"

@implementation IsItAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
