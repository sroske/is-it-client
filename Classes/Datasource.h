//
//  Datasource.h
//  IsIt
//
//  Created by Shawn Roske on 5/6/09.
//  Copyright 2009 Bitgun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Datasource : NSObject {
  NSMutableArray *questions;
  BOOL lastRetrieveSucceeded;
  BOOL appendedLastQuestion;
  int currentPage;
}

+ (Datasource *) sharedDatasource;

- (NSInteger) questionsCountPerPage;
- (NSInteger) questionCount;
- (NSDictionary *) dataForQuestion: (NSInteger) index;

- (BOOL) retrieveMoreQuestions;
- (void) cleanupOldQuestions;

@end
