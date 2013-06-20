//
//  YAJLViewController.h
//  YAJLDemo
//
//  Created by Gautam Lodhiya on 07/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSONParser.h"

@interface YAJLViewController : UIViewController<JSONParserDelegate> {
    UIButton *parseStreamJSONButton;
    UIButton *parseCompleteJSONButton;
    UILabel *outputLabel;
    UITextView *outputTextView;
}

@property (nonatomic, strong)JSONParser *parser;
@property (nonatomic, assign)YAJLParserStatus status;

@end
