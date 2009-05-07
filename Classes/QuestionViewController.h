//
//  QuestionViewController.h
//  IsIt
//
//  Created by Shawn Roske on 5/4/09.
//  Copyright 2009 Bitgun. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface QuestionViewController : UIViewController {
	IBOutlet UILabel *questionLabel;
	IBOutlet UILabel *answerLabel;

  NSInteger questionIndex;
}

@property NSInteger questionIndex;

- (void) fadeOutAnswer;
- (void) fadeInAnswer;

@end
