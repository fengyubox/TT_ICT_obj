//
//  AppDelegate.h
//  TT_ICT
//
//  Created by 曹伟东 on 2018/12/20.
//  Copyright © 2018年 曹伟东. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "myPassWord.h"
#import "UnitView.h"
#import "ScanSN.h"
#import "TTLogView.h"
#import "ZMQObjC.h"
#import "welcomeView.h"
#import "ExitView.h"
#import "ConfigView.h"
#import "CocoaSecurity.h"

@interface AppDelegate : NSObject <NSApplicationDelegate,ConfigViewDelegate, UnitViewDelegate,ScanSNDelegate,PassWordDelegate,WelcomeViewDelegate,ExitViewDelegate>
{
    IBOutlet NSWindow *window;
    IBOutlet NSTextField *_debugLabel;
    IBOutlet NSButton *_startBtn;
    IBOutlet NSTextField *_snTF;
    //main NSWindow ViewVontroller
    IBOutlet NSViewController *_mainVC;
    IBOutlet NSTextField *_swNameLabel;
    IBOutlet NSTextField *_swVersionLabel;
    //Yield Panel
    IBOutlet NSButton *_clearBtn;
    IBOutlet NSTextField *_inputLabel;
    IBOutlet NSTextField *_passLabel;
    IBOutlet NSTextField *_failLabel;
    IBOutlet NSTextField *_yieldLabel;
    //Status Panel
    IBOutlet NSTextField *_timerLabel;
    IBOutlet NSTextField *_statusLabel;
    
    IBOutlet NSButton *_logoBtn;
    //Menu Items
    IBOutlet NSMenuItem *_testModeMI;
    IBOutlet NSMenuItem *_debugModeMI;
    IBOutlet NSMenuItem *_modeMenu;
    
    //Loop test
    IBOutlet NSBox *_loopBox;
    IBOutlet NSTextField *_circleTField;
    IBOutlet NSTextField *_finishLabel;
    IBOutlet NSButton *_abortLoop;
    
    //TT Frame config button
    IBOutlet NSButton *_TTConfigBtn;
    
}
-(IBAction)snTFAction:(id)sender;
-(IBAction)startBtnAction:(id)sender;
-(IBAction)clearBtnAction:(id)sender;
-(IBAction)logoBtnAction:(id)sender;
-(IBAction)testModeMIAction:(id)sender;
-(IBAction)debugModeMIAction:(id)sender;
-(IBAction)abortLoopAction:(id)sender;
-(IBAction)TTConfigBtnAction:(id)sender;
@end

/*
 testplan => AppDelegate.m UnitView.m DetialView.m
 
 
 */
