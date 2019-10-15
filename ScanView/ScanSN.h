//
//  ScanSN.h
//  TT_ICT
//
//  Created by 曹伟东 on 2018/12/22.
//  Copyright © 2018年 曹伟东. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol ScanSNDelegate<NSObject>
-(void)send2TT_SNs:(NSArray *)message;
@end

@interface ScanSN: NSViewController<ScanSNDelegate>
{
    IBOutlet NSTextField *_inputSN_TF;
    IBOutlet NSTextField *_showSN_TF;
    IBOutlet NSButton *_backBtn;
}

@property (nonatomic,weak) id<ScanSNDelegate> delegate;

@property (nonatomic,assign) int UNIT_COUNT;
@property (nonatomic) NSString *_firstSN;
@property (nonatomic,strong) NSMutableArray *_snArr;
@property (nonatomic) bool _isTestMode;

@property (nonatomic) NSDictionary *_rootSet;

@property (nonatomic) NSMutableArray *_select_Slot_BoolArr;

-(IBAction)inputSNAction:(id)sender;
-(IBAction)backBtnAction:(id)sender;

-(BOOL)SNisOK:(NSString *)sn;
-(void)initScanSnView;
@end
