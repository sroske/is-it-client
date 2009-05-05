//
//  IsItAppDelegate.h
//  IsIt
//
//  Created by Shawn Roske on 5/4/09.
//  Copyright Bitgun 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IsItViewController;

@interface IsItAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    IsItViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet IsItViewController *viewController;

@end

