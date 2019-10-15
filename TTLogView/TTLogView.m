//
//  TTLogView.m
//  TT_ICT
//
//  Created by 曹伟东 on 2018/12/26.
//  Copyright © 2018年 曹伟东. All rights reserved.
//

#import "TTLogView.h"

@interface TTLogView ()

@end

@implementation TTLogView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self setTitle:@"TT LogView"];
    [self logUpdate:@"LogView Load..."];
}
-(IBAction)backBtnAction:(id)sender{
    [self dismissViewController:self];
    self._isShowView=NO;
}
-(void)printTTLogString:(NSString *)log{
    [self performSelectorOnMainThread:@selector(logUpdate:) withObject:log waitUntilDone:YES];
}
-(void)logUpdate:(NSString *)log{
    @synchronized(self) {
        NSDateFormatter *dateFormat=[[NSDateFormatter alloc] init];
        [dateFormat setDateStyle:NSDateFormatterMediumStyle];
        [dateFormat setDateStyle:NSDateFormatterShortStyle];
        [dateFormat setDateFormat:@"[yyyy-MM-dd HH:mm:ss.SSS]"];
        
        NSString *dateText=[NSString string];
        dateText=[dateFormat stringFromDate:[NSDate date]];
        //dateText=[dateText stringByAppendingString:@"\n"];
        //_logString = [_logString stringByAppendingString:@"\r\n==============================\r\n"];
        self._logString = [self._logString stringByAppendingString:dateText];
        self._logString = [self._logString stringByAppendingString:log];
        self._logString = [self._logString stringByAppendingString:@"\r\n"];
        if(self._isShowView){
            [self->__logView setString:self->__logString];
            [self->__logView scrollRangeToVisible:NSMakeRange([[self->__logView textStorage] length],0)];
            [self->__logView setNeedsDisplay: YES];
        }
        //if([self._logString length] >10000) self._logString=@"";
    }
}
-(void)viewWillDisappear{
    self._isShowView=NO;
}
@end
