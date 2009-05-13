//
//  QuestionViewController.h
//  IsIt
//
//  Created by Shawn Roske on 5/4/09.
//  Copyright 2009 Bitgun. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "FontLabel.h"

@interface QuestionViewController : UIViewController {
    //FontLabel *questionLabel;
    //FontLabel *answerLabel;
    IBOutlet UILabel *questionLabel;
    IBOutlet UILabel *answerLabel;
    NSInteger questionIndex;
}

@property NSInteger questionIndex;

- (void) fadeInAnswer;
- (void) answerFadedIn: (NSString *) animationID
              finished: (BOOL) finished
               context: (void *) context;

@end
