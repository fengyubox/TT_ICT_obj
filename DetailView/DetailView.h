//
//  DetailView.h
//  TT_ICT
//
//  Created by 曹伟东 on 2018/12/23.
//  Copyright © 2018年 曹伟东. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//parse Testplan.csv
#import "parseCSV.h"


//@interface DetailView : NSViewController<NSTableViewDelegate,NSTableViewDataSource>
@interface DetailView : NSViewController
{
    IBOutlet NSButton *_backBtn;
    IBOutlet NSButton *_testBtn;
    IBOutlet NSTableView *_tableView;
    IBOutlet NSTextField *_titleLabel;
    //IBOutlet NSSplitView *_splitView;
}

//设置tableview代理
//@property (nullable, weak) IBOutlet id<NSTableViewDataSource> dataSource;
//@property (nullable, weak) IBOutlet id<NSTableViewDelegate> delegate;
@property (nonatomic) int _id;

@property (nonatomic) IBOutlet NSTextView *_logView;
@property (nonatomic) IBOutlet NSString *_logString;
@property (nonatomic) BOOL _isShowView;

-(void)initDetailView;
//-(void)loadItems;
-(void)resetTView;
-(void)updateTVWithTesting;
-(void)updateTVWithValue:(NSString *)value duration:(NSTimeInterval )dur result:(NSString *)result row:(int )index;
-(void)printLogString:(NSString *)log;
-(IBAction)backBtnAction:(id)sender;
-(IBAction)testBtnAction:(id)sender;



@end
