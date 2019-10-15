//
//  TTLogView.h
//  TT_ICT
//
//  Created by 曹伟东 on 2018/12/26.
//  Copyright © 2018年 曹伟东. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TTLogView : NSViewController
{
    IBOutlet NSButton *_backBtn;
}

@property (nonatomic) IBOutlet NSTextView *_logView;
@property (nonatomic) NSString *_logString;
@property (nonatomic) BOOL _isShowView;
-(IBAction)backBtnAction:(id)sender;

-(void)printTTLogString:(NSString *)log;

@end
