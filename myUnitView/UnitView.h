//
//  SubView2.h
//  layoutTest
//
//  Created by 曹伟东 on 2018/12/16.
//  Copyright © 2018年 曹伟东. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//ZMQ class,just for test socket
#import "ZMQObjC.h"
//Slot Detail TableView
#import "DetailView.h"
//Slot Config View,such as DUT serialport,NIVISA Instruments,Socket device
#import "ConfigView.h"
//parse Testplan.csv
#import "parseCSV.h"
//update PDCA
#import "InstantPudding.h"
//progress bar HUD
#import "MyProgressView.h"

@protocol UnitViewDelegate<NSObject>
-(void)send2TTdata:(NSString *)data;
@end


@interface UnitView : NSViewController<UnitViewDelegate,ConfigViewDelegate>
{
    DetailView *_detailView;
    myConfigView *_configView;
    InstantPudding *_pdca;
    MyProgressView *_myProgressView;
    IBOutlet NSView *_view;
    IBOutlet NSTextField *_snLabel;
    IBOutlet NSProgressIndicator *_progressIndicator1;
}
//@property (weak) IBOutlet NSColorWell *_color;
@property (weak) IBOutlet NSBox *_box;
@property (weak) IBOutlet NSButton *_callDetialBtn;
@property (weak) IBOutlet NSButton *_selectedBtn;
@property (weak) IBOutlet NSButton *_configBtn;

@property (nonatomic) int _id;
//test config root set
@property (nonatomic) NSDictionary *_rootSet;

@property (nonatomic,assign) BOOL _pdcaEnable;

@property (nonatomic,weak) id<UnitViewDelegate> delegate;

-(IBAction)SelectedBtnAction:(id)sender;
-(IBAction)callDetailAction:(id)sender;
-(IBAction)configBtnAction:(id)sender;

-(void)receiveTTdata:(NSString *)data;

NSInteger intSort(id num1, id num2, void *context);

@end

