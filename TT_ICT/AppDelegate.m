//
//  AppDelegate.m
//  TT_ICT
//
//  Created by 曹伟东 on 2018/12/20.
//  Copyright © 2018年 曹伟东. All rights reserved.
//

#import "AppDelegate.h"
#import "MapIndex.h"

@interface AppDelegate ()
@property (nonatomic,strong) welcomeView *welcomePage;
@property (nonatomic,strong) ScanSN *scanSN;
@property (nonatomic,strong) TTLogView *ttLogView;
@property (nonatomic,strong) myPassWord *passwordVC;
@property (nonatomic,strong) ExitView *exitView;
@property (nonatomic,strong) myConfigView *ttConfigView;
@property (nonatomic,strong) NSDictionary *rootSet; //Root Set Dictionary
@property (nonatomic,strong) NSDictionary *testSet; //Test Set Dictionary
@property (nonatomic,strong) NSMutableArray *unitsArr; //Unit view Array
@property (nonatomic,strong) NSMutableArray *snArr;
@property (nonatomic,strong) NSString *csvData;
@property (nonatomic,strong) NSString *swName;
@property (nonatomic,strong) NSString *swVersion;
@property (nonatomic,strong) NSString *scriptName;
@property (nonatomic,strong) NSThread *mainThread;
@property (nonatomic,assign) int inputCount;
@property (nonatomic,assign) int passCount;
@property (nonatomic,assign) int failCount;
@property (nonatomic,strong) NSTimer *timer;

@property (nonatomic,assign) BOOL TESTING_FLAG;
@property (nonatomic,assign) BOOL SN_READY;
@property (nonatomic,assign) int COUNT_SELECTED_UNIT;
@property (nonatomic,assign) int COUNT_FINISHED_UNIT;
@property (nonatomic,strong) NSLock *lock;
@property (nonatomic,strong) NSString *TT_testResult;
@property (nonatomic,strong) NSString *MODE;
@property (nonatomic,assign) BOOL PDCA_ENABLE;
@property (nonatomic,assign) int COUNT_SLOT_EXIT_IS_OK;
@property (nonatomic,assign) BOOL FLAG_ALL_SLOT_EXIT_IS_OK;
//Loop Test
@property (nonatomic,assign) BOOL ABORT_LOOP;
@property (nonatomic,assign) int COUNT_LOOP_CIRCLE;
@property (nonatomic,assign) int COUNT_FINISHED_CIRCLE;
@property (nonatomic,strong) NSString *TT_log;
@property (nonatomic,assign) int UNIT_COUNT;
//Task sync
@property (nonatomic,assign) BOOL TASK_KEY_isOK;
@property (nonatomic,assign) int SYNC_TASK_REQUEST_COUNT;
//Extened scripts
@property (nonatomic,strong) NSArray *startScriptArr;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    /*-----------------------Welcome View------------------------------*/
    _welcomePage=[[welcomeView alloc] initWithWindowNibName:@"welcomeWin"];
    _welcomePage.delegate=self;
    _welcomePage.autoLogin=YES;
    _welcomePage.userName=@"TE";
    _welcomePage.passWord=@"123";
    [_welcomePage showWindow:_welcomePage.window];
    /*-----------------------End Welcome View--------------------------*/
    NSLog(@"launch done.");
    
}
/*0.*/
-(void)verifySecure{
    NSString *rawfilePath=[[NSBundle mainBundle] resourcePath];
    rawfilePath=[rawfilePath stringByAppendingPathComponent:@"/securityFolder"];
    BOOL isSecure= [self CheckSecurityFolder:rawfilePath];
    NSLog(@"Security folder check result:%hhd",isSecure);
    if (YES == isSecure) {
        [self myPrintf:@"Verify secure OK!",nil];
    }else{
        [self performSelectorOnMainThread:@selector(alarmPanel:) withObject:@"Verify secure NG!" waitUntilDone:YES];
        [NSApp terminate:self];
    }
}
/*1.*/
-(void)initParams{
    /*get units count from TestConfig.plist */
    _COUNT_SELECTED_UNIT=_UNIT_COUNT;
    _SYNC_TASK_REQUEST_COUNT=0;
    
    _COUNT_FINISHED_UNIT=0;
    //Loop test
    _ABORT_LOOP = NO;
    _COUNT_FINISHED_CIRCLE=0;
    
    _TASK_KEY_isOK = YES;
    
    _TESTING_FLAG=NO;
    _SN_READY=NO;
    _FLAG_ALL_SLOT_EXIT_IS_OK=NO;
    _COUNT_SLOT_EXIT_IS_OK=0;
    _lock=[[NSLock alloc] init];
    _TT_testResult=@"PASS";
    _MODE=@"TEST";
    
    NSLog(@"_mainVC:%@",_mainVC);
    _unitsArr=[[NSMutableArray alloc] initWithCapacity:1];
    for (int i=0; i<_UNIT_COUNT; i++) {
        UnitView *unitView=[[UnitView alloc] initWithNibName:@"UnitView" bundle:nil];
        [_unitsArr addObject:unitView];
    }
    NSLog(@"_unitArr count:%ld",[_unitsArr count]);
}
/*2.*/
-(void)executeScriptsFunc{
    for (NSString *cmd in _startScriptArr) {
        NSString *result=[self cmdExe:cmd];
        [self myPrintf:result,nil];
    }
    
    NSString *rawfilePath=[[NSBundle mainBundle] resourcePath];
    NSString *cmd=[rawfilePath stringByAppendingPathComponent:@"/ExtendScripts/myPyServer.py"];
    cmd=[@"python " stringByAppendingString:cmd];
    [self myPrintf:cmd,nil];
    //const char *cmdC=[cmd UTF8String];
    //system(cmdC);
    [self syncEcecutePythonCmd:cmd];
}
/*2.*/
-(void)loadLogView{
    _ttLogView=[[TTLogView alloc]initWithNibName:@"TTLogView" bundle:nil];
    _ttLogView._logString=@"";
}
/*3.*/
-(void)loadUnitView{
    [window.contentView setFrame:CGRectMake(0,0, 1000, 700)];
    //unit view size:x=400,y=300
    int x=0;
    int y=310;
    for(int i=0;i<_unitsArr.count;i++){
        UnitView *item=[_unitsArr objectAtIndex:i];
        item._id=i+1;
        item._rootSet=_rootSet;
        item._pdcaEnable=_PDCA_ENABLE;
        [item.view setFrame:CGRectMake(x, y, item.view.frame.size.width, item.view.frame.size.height)];
        item.delegate=self;
        [window.contentView addSubview:item.view];
        [item._selectedBtn setTitle:[NSString stringWithFormat:@"Slot-%d",i+1]];
        
        x+=400;
        if (i == 1) {
            x=0;
            y=0;
        }
        
    }
}
/*4.*/
-(void)loadScanSNView{
    //init scanSN ViewController
    _scanSN=[[ScanSN alloc]initWithNibName:@"ScanSN" bundle:nil];
    _scanSN.delegate=self; //protocol delegate init **
    _scanSN._select_Slot_BoolArr=[[NSMutableArray alloc]initWithCapacity:_UNIT_COUNT];
    _scanSN._rootSet=_rootSet;
    _scanSN.UNIT_COUNT=_UNIT_COUNT;
    [_scanSN initScanSnView];
    
}
/*5.*/
-(void)loadTTConfigView{
    _ttConfigView=[[myConfigView alloc] initWithNibName:@"ConfigView" bundle:nil];
    _ttConfigView.delegate=self;
    _ttConfigView.dictKey=@"TTFrame";
    [_ttConfigView initView];
}
/*6.*/
-(void)initUI{
    [_TTConfigBtn setHidden:YES];
    [_debugLabel setHidden:YES];
    [_swNameLabel setStringValue:_swName];
    [_swVersionLabel setStringValue:_swVersion];
    [self updateYield:NO];
    NSString *windowTitle=[NSString stringWithFormat:@"Script:..\\%@",_scriptName];
    [window setTitle:windowTitle];
    
    
}

-(void)loadProgressThread{
    /*0.*/
    [_welcomePage updateStatus:@"verify security..." progress:10.0];
    [self verifySecure];
    [NSThread sleepForTimeInterval:0.5];
    /*1.*/
    [_welcomePage updateStatus:@"init params..." progress:20.0];
    [self initParams];
    [NSThread sleepForTimeInterval:0.2];
    /*2.*/
    [_welcomePage updateStatus:@"execute scripts..." progress:30.0];
    [self performSelectorOnMainThread:@selector(executeScriptsFunc) withObject:nil waitUntilDone:YES];
    [NSThread sleepForTimeInterval:0.5];
    /*2.*/
    [_welcomePage updateStatus:@"load log view..." progress:40.0];
    [self performSelectorOnMainThread:@selector(loadLogView) withObject:nil waitUntilDone:YES];
    [NSThread sleepForTimeInterval:0.5];
    /*3.*/
    [_welcomePage updateStatus:@"load unit view..." progress:50.0];
    [self performSelectorOnMainThread:@selector(loadUnitView) withObject:nil waitUntilDone:YES];
    [NSThread sleepForTimeInterval:0.5];
    /*4.*/
    [_welcomePage updateStatus:@"load scan sn view..." progress:80.0];
    [self performSelectorOnMainThread:@selector(loadScanSNView) withObject:nil waitUntilDone:YES];
    [NSThread sleepForTimeInterval:0.5];
    /*5.*/
    [_welcomePage updateStatus:@"load TT config view..." progress:90.0];
    [self performSelectorOnMainThread:@selector(loadTTConfigView) withObject:nil waitUntilDone:YES];
    [NSThread sleepForTimeInterval:0.5];
    /*6.*/
    [_welcomePage updateStatus:@"load main UI..." progress:100.0];
    [self performSelectorOnMainThread:@selector(initUI) withObject:nil waitUntilDone:YES];
    [NSThread sleepForTimeInterval:0.5];
    [_welcomePage closePage];
    dispatch_async(dispatch_get_main_queue(), ^{
        //通知主线程更新
        [self->window setIsVisible:YES];
    });
    /*!just for debug
     *press debug mode menu
     */
    [NSThread sleepForTimeInterval:1.0];
    dispatch_async(dispatch_get_main_queue(), ^{
        //通知主线程更新
        [self debugModeMIAction:self->_debugModeMI];
    });
    
    NSLog(@"load progress finish");
}
-(BOOL)CheckSecurityFolder:(NSString *)folder{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 取得一个目录下得所有文件名
    NSArray *files = [fileManager subpathsAtPath:folder];
    NSLog(@"files:%@",files);
    
    for (NSString *fileName in files) {
        if ([fileName hasSuffix:@".signed"]) {
            continue;
        }
        NSString *file = [folder stringByAppendingString:@"/"];
        file = [file stringByAppendingString:fileName];
        NSLog(@"\n==>%@",file);
        NSString *readStr = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
        //NSLog(@"读取文件-字符串： %@", readStr);
        CocoaSecurityResult *result_md5 = [CocoaSecurity md5:readStr];
        
        NSString *md5_val=[result_md5 base64];
        NSLog(@"md5 value:%@", md5_val);
        
        NSString *signed_file=[file stringByAppendingString:@".signed"];
        if (![fileManager fileExistsAtPath:signed_file]) {
            NSLog(@"Signed file not exist!");
            return NO;
        }
        NSString *encrypt_val=[NSString stringWithContentsOfFile:signed_file encoding:NSUTF8StringEncoding error:nil];
        //decrypt md5 val
        CocoaSecurityResult *aes256Decrypt =
        [CocoaSecurity aesDecryptWithBase64:encrypt_val hexKey:mainKey hexIv:subKey];
        // aes256Decrypt.utf8String = 'kelp'
        NSString *decrypt_val=[aes256Decrypt utf8String];
        NSLog(@"Decrypt val:%@",decrypt_val);
        
        if ([decrypt_val isEqualToString:md5_val]) {
            NSLog(@"Check security result:OK");
        }else{
            NSLog(@"Check security result:NG");
            return NO;
        }
    }
    
    return YES;
}
#pragma welcome view delegate event
-(void)msgFromWelcomeView:(NSString *)msg{
    NSLog(@"msg:%@",msg);
    if ([msg isEqualToString:@"cancel"]) {
        //[[window standardWindowButton:NSWindowCloseButton] performClick:self];
        [NSApp terminate:self];
        return;
    }
    if([msg isEqualToString:@"login"]){
        [self performSelectorInBackground:@selector(loadProgressThread) withObject:nil];
    }
    
}
//message from Config View
- (void)msgFromConfigView:(NSString *)msg {
    [self myPrintf:@"msg:",msg,@" from config view",nil];
    //DUT connect status:"STATUS:0"
    if ([msg hasPrefix:@"STATUS"]) {
        NSArray *tempArr=[msg componentsSeparatedByString:@":"];
        BOOL status=[tempArr[1] boolValue];
        
    }
}
-(id)init{
    [self myPrintf:@"Init...",nil];
    _scriptName=@"StationConfig.plist";
    //_mainVC=[[NSViewController alloc]init];
    //_mainVC=self.window.contentViewController;
    NSString *rawfilePath=[[NSBundle mainBundle] resourcePath];
    NSString *filePath;
    filePath=[rawfilePath stringByAppendingPathComponent:_scriptName];
    _rootSet=[[NSDictionary alloc] initWithContentsOfFile:filePath];
    _testSet=[_rootSet objectForKey:@"cfg"];
    _swName=[_testSet objectForKey:@"SWname"];
    _swVersion=[_testSet objectForKey:@"SWversion"];
    _UNIT_COUNT=[[_testSet objectForKey:@"UnitCount"] intValue];
    _PDCA_ENABLE=[[_testSet objectForKey:@"PDCAenable"] boolValue];
    _testSet=[_rootSet objectForKey:@"yield"];
    _inputCount = [[_testSet objectForKey:@"Input"] intValue];
    _passCount=[[_testSet objectForKey:@"Pass"] intValue];
    _failCount=_inputCount-_passCount;
    
    _startScriptArr=[_rootSet objectForKey:@"startScripts"];
    
    return self;
}
-(void)updateYield:(bool )save_flag{
    _inputCount = _failCount + _passCount;
    [_inputLabel setStringValue:[NSString stringWithFormat:@"Input:%d",_inputCount]];
    [_passLabel setStringValue:[NSString stringWithFormat:@"Pass:%d",_passCount]];
    [_failLabel setStringValue:[NSString stringWithFormat:@"Fail:%d",_failCount]];
    NSString *yieldStr = @"Yield:0.00%";
    if(_inputCount != 0){
        float yield = (_passCount*1.0000/_inputCount) *100;
        yieldStr=[NSString stringWithFormat:@"Yield:%.2f",yield];
        yieldStr=[yieldStr stringByAppendingString:@"%"];
        [_yieldLabel setStringValue:yieldStr];
    }else{
        [_yieldLabel setStringValue:yieldStr];
    }
    NSLog(@"input:%d pass:%d fail:%d yield:%@",_inputCount,_passCount,_failCount,yieldStr);
    if(save_flag){
        _testSet =[_rootSet objectForKey:@"yield"];
        [_testSet setValue:[NSNumber numberWithInt:_inputCount] forKey:@"Input"];
        [_testSet setValue:[NSNumber numberWithInt:_passCount] forKey:@"Pass"];
        [_rootSet setValue:_testSet forKey:@"yield"];
        NSString *portFilePath=[[NSBundle mainBundle] resourcePath];
        portFilePath =[portFilePath stringByAppendingPathComponent:_scriptName];
        [_rootSet writeToFile:portFilePath atomically:NO];
    }
}
-(IBAction)logoBtnAction:(id)sender{
    _ttLogView._isShowView=YES;
    [self myPrintf:@"Open TT LogView...",nil];
    [_ttLogView.view setFrameSize:NSMakeSize(640, 450)];
    [_mainVC presentViewControllerAsModalWindow:_ttLogView];
}
-(IBAction)clearBtnAction:(id)sender{
    _failCount=0;
    _passCount=0;
    [self updateYield:YES];
    [self rightPanel:@"Clear Successful!"];
}
-(IBAction)startBtnAction:(id)sender{
    [self myPrintf:@"\n[TAG]-------Start Test------\n",nil];
    //Loop test
    _COUNT_LOOP_CIRCLE=[_circleTField intValue];
    [_finishLabel setIntValue:_COUNT_FINISHED_CIRCLE+1];
    if ([_MODE isEqualToString:@"DEBUG"] && !_ABORT_LOOP) {
        [_abortLoop setHidden:NO];
    }
    
    //scan sn finish?
    if (!_SN_READY) {
        [self alarmPanel:@"Scan SN first!"];
        return;
    }
    
    [self saveTTLog];
    _ttLogView._logString=@"";
    
    //init before testing
    _csvData=@"";
    _TESTING_FLAG=YES;
    _COUNT_FINISHED_UNIT=0;
    _SYNC_TASK_REQUEST_COUNT=0;
    [_timerLabel setStringValue:@"0 s"];
    [_snTF setEnabled:NO];
    [_startBtn setEnabled:NO];
    [_modeMenu setEnabled:NO];
    [_TTConfigBtn setEnabled:NO];
    [_clearBtn setEnabled:NO];
    [NSThread detachNewThreadSelector:@selector(testTimeTrack) toTarget:self withObject:nil];
    _TT_testResult=@"PASS";
    //send "START" to every unit view
    for (int i=0; i<_UNIT_COUNT; i++) {
        UnitView *item=[_unitsArr objectAtIndex:i];
        [item._selectedBtn setEnabled:NO];
        [item._configBtn setEnabled:NO];
        if ([item._selectedBtn state]) {
            [item receiveTTdata:@"START"];
        }
    }
    /*---for debug test function
     if(![mainThread isExecuting]){
     mainThread=[[NSThread alloc] initWithTarget:self selector:@selector(testThread) object:nil];
     [mainThread start];
     }
     */
}
//present TT ConfigView
-(IBAction)TTConfigBtnAction:(id)sender{
    [_mainVC presentViewControllerAsModalWindow:_ttConfigView];
    [self myPrintf:@"present TT ConfigView...",nil];
}
/*
 -(void)testThread{
 for (int i=0; i<5; i++) {
 NSLog(@"testing...%d",i);
 [NSThread sleepForTimeInterval:0.5];
 }
 _TESTING_FLAG=NO;
 }
 */
/*
 //send data to UnitView
 -(IBAction)sendBtnAction:(id)sender{
 
 [_subview1 receiveTTdata:@"SN:123"];
 [_subview2 receiveTTdata:@"SN:456"];
 
 }
 */

//receive data from UnitView
- (void)send2TTdata:(NSString *)data{
    [_lock lock];
    [self myPrintf:@"msg:",data,@" from unit view",nil];
    //Finish:1:FAIL
    if (([data hasPrefix:@"Finish"])) {
        
        _COUNT_FINISHED_UNIT+=1;
        _SYNC_TASK_REQUEST_COUNT+=1;
        NSArray *tempArr=[data componentsSeparatedByString:@":"];
        if ([[tempArr objectAtIndex:2] isEqualToString:@"FAIL"]) {
            _TT_testResult=@"FAIL";
            _failCount += 1;
        }else{
            _passCount += 1;
        }
        NSLog(@"cfu:%d csu:%d",_COUNT_FINISHED_UNIT,_COUNT_SELECTED_UNIT);
        //check finished count
        if(_COUNT_FINISHED_UNIT == _COUNT_SELECTED_UNIT){
            //[self->_statusLabel setStringValue:[NSString stringWithFormat:@"Done"]];
            //[self->_statusLabel setBackgroundColor:[NSColor systemGreenColor]];
            
            //Loop test finished mark
            _COUNT_FINISHED_CIRCLE +=1;
            [self myPrintf:@"_TT_testResult:",_TT_testResult,nil];
            
            [self myPrintf:@"All unit finish test program.",nil];
            
            //save CSV data
            [self writeData2Csv];
            
            _TESTING_FLAG=NO;
            
            NSString *circleStr=[NSString stringWithFormat:@"%d",_COUNT_FINISHED_CIRCLE];
            [self myPrintf:@"_COUNT_FINISHED_CIRCLE:",circleStr,nil];
            
            //check abort loop ?
            if (_ABORT_LOOP) {
                _SN_READY=NO;
                _COUNT_FINISHED_CIRCLE=0;
                _ABORT_LOOP=NO;
                
                //return;
            }else{
                //check loop test finish?
                if(_COUNT_FINISHED_CIRCLE == _COUNT_LOOP_CIRCLE){
                    _SN_READY=NO;
                    _COUNT_FINISHED_CIRCLE=0;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //回调或者说是通知主线程刷新，
                        [self->_abortLoop setHidden:YES];
                    });
                    
                }else{
                    [NSThread detachNewThreadSelector:@selector(nextLoopCircle) toTarget:self withObject:nil];
                }
            }
        }
    }
    //"Selected:1:1" --selected ID 0 or 1
    else if([data hasPrefix:@"Selected"]){
        NSArray *tempArr=[data componentsSeparatedByString:@":"];
        int tagInt=[tempArr[2] isEqual:@"1"] ? 1 : -1;
        if (1 == tagInt) {
            _SN_READY = NO;
        }
        _COUNT_SELECTED_UNIT+=tagInt;
        NSString *tmpStr=[NSString stringWithFormat:@"%d",_COUNT_SELECTED_UNIT];
        [self myPrintf:@"_COUNT_SELECT_UNIT:",tmpStr,nil];
    }
    //"CSVDATA#SN001,PASS,NA,......"
    else if([data hasPrefix:@"CSVDATA"]){
        
        NSArray *tempArr=[data componentsSeparatedByString:@"#"];
        NSString *data=tempArr[1];
        _csvData=[_csvData stringByAppendingString:data];
    }
    //"GetKEY:0/1/2/3...
    else if([data hasPrefix:@"GetKEY"]){
        NSString *indexStr=[data componentsSeparatedByString:@":"][1];
        UnitView *item=[_unitsArr objectAtIndex:[indexStr intValue]];
        if (YES == _TASK_KEY_isOK) {
            [item receiveTTdata:@"TASK_KEY_IS_OK"];
            _TASK_KEY_isOK = NO;
        }else{
            [item receiveTTdata:@"TASK_KEY_IS_NG"];
        }
    }
    //"ReturnKEY"
    else if([data isEqualToString:@"ReturnKEY"]){
        _TASK_KEY_isOK = YES;
    }
    //"RequestSyncTask:Is this a sync task?"
    else if([data hasPrefix:@"RequestSyncTask"]){
        _SYNC_TASK_REQUEST_COUNT+=1;
        if (_SYNC_TASK_REQUEST_COUNT == _COUNT_SELECTED_UNIT) {
            NSString *cmd=[data componentsSeparatedByString:@"#"][1];
            [self performSelectorInBackground:@selector(executeSyncTask:) withObject:cmd];
            //[self performSelectorOnMainThread:@selector(executeSyncTask:) withObject:cmd waitUntilDone:NO];
        }
    }
    //"OK,EXIT"
    else if([data hasPrefix:@"EXIT"]){
        _COUNT_SLOT_EXIT_IS_OK += 1;
        if (_COUNT_SLOT_EXIT_IS_OK == _UNIT_COUNT) {
            _FLAG_ALL_SLOT_EXIT_IS_OK=YES;
        }
    }
    //[NSThread sleepForTimeInterval:1.0f];
    [_lock unlock];
}
//Loop test =>next loop circle
-(void)nextLoopCircle{
    [NSThread sleepForTimeInterval:0.5f];
    //send arrSNs to every UnitView
    dispatch_async(dispatch_get_main_queue(), ^{
        //回调或者说是通知主线程刷新，
        [self sendSN2UnitView];
    });
    
    //delay 100ms
    [NSThread sleepForTimeInterval:0.1f];
    //click start button
    dispatch_async(dispatch_get_main_queue(), ^{
        //回调或者说是通知主线程刷新，
        [self->_startBtn performClick:self];
    });
    
}
//execute sync task, this in background thread now
-(void)executeSyncTask:(NSString *)cmd{
    NSString *response=@"NA";
    //[self alarmPanel:cmd];
    NSArray *msg_arr=[cmd componentsSeparatedByString:@":"];
    if ([msg_arr count] < 2) {
        response = @"ERROR";
    }
    else{
        NSString *thisFunction=[msg_arr objectAtIndex:0];
        NSString *thisCommand=[msg_arr objectAtIndex:1];
        if ([thisFunction isEqualToString:@"socket"]) {
            response=[_ttConfigView sendCmd:thisCommand TimeOut:2.0 withName:@"PYClient"];
            
        }
    }
    
    [self myPrintf:@"executeSyncTask:",cmd,@" response:",response,nil];
    response=[response stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    response=[response stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    response=[response stringByReplacingOccurrencesOfString:@"#" withString:@"@"];
    NSString *reply_msg=[@"SYNC_TASK_DONE#" stringByAppendingString:response];
    //send msg to every unit view
    [self performSelectorOnMainThread:@selector(sendMsg2Units:) withObject:reply_msg waitUntilDone:YES];
    _SYNC_TASK_REQUEST_COUNT=0;
}
//send msg to all selected unit
-(void)sendMsg2Units:(NSString *)msg{
    for (int i=0; i<_UNIT_COUNT; i++) {
        UnitView *item=[_unitsArr objectAtIndex:i];
        if ([item._selectedBtn state]) {
            [item receiveTTdata:msg];
        }
    }
    
}
//get password result
-(void)send2TT_PassWord:(BOOL )message{
    NSLog(@"password result:%hhd",message);
    if(!message){
        [self testModeMIAction:_testModeMI];
        return;
    }
    _MODE=@"DEBUG";
    [self updateMode];
    
}
-(void)updateMode{
    //MODE:DEBUG
    if ([_MODE isEqualToString:@"DEBUG"]) {
        [_debugModeMI setTitle:@"Debug*"];
        [_testModeMI setTitle:@"Test"];
        [window setBackgroundColor:[NSColor colorWithRed:255.0/255.0 green:192.0/255.0 blue:203.0/255.0 alpha:1.0]];
        [_debugLabel setHidden:NO];
        [_TTConfigBtn setHidden:NO];
        for (int i=0; i<_UNIT_COUNT; i++) {
            UnitView *item=[_unitsArr objectAtIndex:i];
            [item receiveTTdata:@"MODE:DEBUG"];
            [NSThread sleepForTimeInterval:0.05f];
        }
        
        //Loop NSBox
        [_loopBox setHidden:NO];
        [_abortLoop setHidden:YES];
        _COUNT_LOOP_CIRCLE=[_circleTField intValue];
        _scanSN._isTestMode=false;
        
    }
    //MODE:TEST
    else{
        [_testModeMI setTitle:@"Test*"];
        [_debugModeMI setTitle:@"Debug"];
        [window setBackgroundColor:[NSColor controlColor]];
        [_debugLabel setHidden:YES];
        [_TTConfigBtn setHidden:YES];
        for (int i=0; i<_UNIT_COUNT; i++) {
            UnitView *item=[_unitsArr objectAtIndex:i];
            [item receiveTTdata:@"MODE:TEST"];
            [NSThread sleepForTimeInterval:0.05f];
        }
        //Loop NSBox
        [_loopBox setHidden:YES];
        _COUNT_LOOP_CIRCLE = 1;
        _scanSN._isTestMode=true;
    }
}
//get SNs from ScanSN ViewController
- (void)send2TT_SNs:(NSArray *)message {
    _snArr=[[NSMutableArray alloc] initWithArray:message];
    for (NSString *sn in _snArr) {
        [self myPrintf:@"sn:",sn,@" from ScanSN view",nil];
    }
    //send sn to every unit view
    [self sendSN2UnitView];
    _SN_READY=YES;
    //after finish scan SN auto start testing
    //[_startBtn performClick:self];
}
-(void)sendSN2UnitView{
    //send sn to every unit view
    for (int i=0; i<_UNIT_COUNT; i++) {
        UnitView *item=[_unitsArr objectAtIndex:i];
        NSString *sn=[_snArr objectAtIndex:i];
        NSString *msg=[NSString stringWithFormat:@"SN:%@",sn];
        if ([item._selectedBtn state]) {
            [item receiveTTdata:msg];
        }
    }
}
#pragma mark-Scan SN TextField Action
-(IBAction)snTFAction:(id)sender{
    _SN_READY=NO; //init scan SN finish flag
    _snArr=[[NSMutableArray alloc] initWithCapacity:1];
    for (int i=0; i<_UNIT_COUNT; i++) {
        [_snArr addObject:@""];
    }
    [self sendSN2UnitView];
    //get first input SN string
    NSString *sn=[_snTF stringValue];
    [_snTF setStringValue:@""];
    [self myPrintf:@"input sn:",sn,nil];
    
    //check SN rule
    _scanSN._snArr =[[NSMutableArray alloc]initWithCapacity:1];
    if([_scanSN SNisOK:sn] == NO) return;
    
    //read selected and unselected
    bool find_Selected_Unit = false; //find selected flag
    int unSelectedCount=0;  //count unseleceted unit
    int selectedFirstIndex=0; //first selected index
    if ([_scanSN._select_Slot_BoolArr count] >0) {
        [_scanSN._select_Slot_BoolArr removeAllObjects];
    }
    for(int i=0;i<_unitsArr.count;i++){
        UnitView *item=[_unitsArr objectAtIndex:i];
        if ([item._selectedBtn state] == YES) {
            [_scanSN._select_Slot_BoolArr addObject:@"YES"];
            if (!find_Selected_Unit) selectedFirstIndex=i;
            find_Selected_Unit=true;
        }else{
            [_scanSN._select_Slot_BoolArr addObject:@"NO"];
            unSelectedCount +=1;
        }
    }
    //no selected any Units
    if (!find_Selected_Unit) {
        [self myPrintf:@"!No selected any Units!",nil];
        [self alarmPanel:@"No selected any Slot!"];
        return;
    }
    
    //just only on selected unit
    if(unSelectedCount == _UNIT_COUNT-1 ){
        //if([_scanSN SNisOK:sn] == NO) return;
        NSMutableArray *tempArr=[[NSMutableArray alloc] initWithCapacity:4];
        for (int i=0; i<_UNIT_COUNT; i++) {
            if (i == selectedFirstIndex){
                [tempArr addObject:sn];
            }else{
                [tempArr addObject:@""];
            }
            
        }
        
        _snArr=[[NSMutableArray alloc] initWithArray:tempArr];
        for (NSString *sn in _snArr) {
            [self myPrintf:@"sn:",sn,nil];
        }
        //send sn to every unit view
        [self sendSN2UnitView];
        _SN_READY=YES;
        //after finish scan SN auto start testing
        //[_startBtn performClick:self];
        return;
    }
    
    //not just one selected,present ScanSn ViewController
    _scanSN._firstSN=sn;
    [_mainVC presentViewControllerAsSheet:_scanSN];
    
}
//Menu Item Action
-(IBAction)testModeMIAction:(id)sender{
    _MODE=@"TEST";
    [self updateMode];
    
}
-(IBAction)debugModeMIAction:(id)sender{
    [self myPrintf:@"Press Debug Mode...",nil];
    if([_debugModeMI.title containsString:@"*"]){
        return;
    }else{
        [self callPassWordVC];
        //return;
    }
    
}
-(IBAction)abortLoopAction:(id)sender{
    _ABORT_LOOP=YES;
    [_abortLoop setHidden:YES];
}
-(void)callPassWordVC{
    _testSet=[_rootSet objectForKey:@"cfg"];
    //init myPassWord ViewController
    _passwordVC=[[myPassWord alloc]initWithNibName:@"myPassWord" bundle:nil];
    _passwordVC.delegate=self; //protocol delegate init **
    _passwordVC._passwordStr=[_testSet objectForKey:@"PassWord"];
    [_mainVC presentViewControllerAsSheet:_passwordVC];
}
//Save local TT_log in log.txt
-(void)saveTTLog{
    NSString *strMonth = [self getCurrentMonth];
    NSString *logPath = [NSString stringWithFormat:@"/vault/%@/%@/TT_log",_swName,strMonth];
    NSString *strCurrentDate = [self getCurrentHour];
    NSString *strFileName = [NSString stringWithFormat:@"TTLog_%@_%@.txt", strCurrentDate,_MODE];
    
    NSString *strFilePath = [NSString stringWithFormat:@"%@/%@", logPath, strFileName];
    
    if(YES == [self createLOGFileWithPath:logPath withFilePath:strFilePath])
    {
        [self appendDataToFileWithString:[_ttLogView _logString] withFilePath:strFilePath];
    }
}
-(BOOL)createLOGFileWithPath:(NSString *)path withFilePath:(NSString *)strLogFilePath
{
    BOOL isDir = NO;
    NSError *errMsg;
    
    //1. Get execution tool's folder path
    NSFileManager *fm = [NSFileManager defaultManager];
    
    //2. If bDirExist&isDir are true, the directory exit
    BOOL bDirExist = [fm fileExistsAtPath:path isDirectory:&isDir];
    if (!(bDirExist == YES && isDir == YES))
    {
        if (NO == [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&errMsg])
            return NO;
    }
    
    //4. Check file exist or not
    //5. If file not exist, creat data to file
    //    bDirExist = [fm fileExistsAtPath:_logFilePath isDirectory:&isDir];
    if (NO == [fm fileExistsAtPath:strLogFilePath isDirectory:&isDir])
    {
        if (NO == [fm createFileAtPath:strLogFilePath contents:nil attributes:nil])
        {
            return NO;
        }
        
        NSString *strSum = [[NSString alloc] init];
        if (NO == [strSum writeToFile:strLogFilePath atomically:YES encoding:NSUTF8StringEncoding error:&errMsg])
        {
            return NO;
        }
        //NSString *strTitle=[self getCsvTitle];
        [self appendDataToFileWithString:@"----NEW LOG----\r\n" withFilePath:strLogFilePath];//第一次创建时，增加INFO
    }
    
    return YES;
}

//Save location data in one csv file
-(void)writeData2Csv
{
    NSString *strMonth = [self getCurrentMonth];
    NSString *csvPath = [NSString stringWithFormat:@"/vault/%@/%@",_swName,strMonth];
    NSString *strCurrentDate = [self getCurrentDate];
    NSString *strFileName = [NSString stringWithFormat:@"%@_%@.csv", strCurrentDate,_MODE];
    
    NSString *strFilePath = [NSString stringWithFormat:@"%@/%@", csvPath, strFileName];
    
    if(YES == [self createCSVFileWithPath:csvPath withFilePath:strFilePath])
    {
        [self appendDataToFileWithString:_csvData withFilePath:strFilePath];
    }
}

-(BOOL)createCSVFileWithPath:(NSString *)path withFilePath:(NSString *)strLogFilePath
{
    BOOL isDir = NO;
    NSError *errMsg;
    
    //1. Get execution tool's folder path
    NSFileManager *fm = [NSFileManager defaultManager];
    
    //2. If bDirExist&isDir are true, the directory exit
    BOOL bDirExist = [fm fileExistsAtPath:path isDirectory:&isDir];
    if (!(bDirExist == YES && isDir == YES))
    {
        if (NO == [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&errMsg])
            return NO;
    }
    
    //4. Check file exist or not
    //5. If file not exist, creat data to file
    //    bDirExist = [fm fileExistsAtPath:_logFilePath isDirectory:&isDir];
    if (NO == [fm fileExistsAtPath:strLogFilePath isDirectory:&isDir])
    {
        if (NO == [fm createFileAtPath:strLogFilePath contents:nil attributes:nil])
        {
            return NO;
        }
        
        NSString *strSum = [[NSString alloc] init];
        if (NO == [strSum writeToFile:strLogFilePath atomically:YES encoding:NSUTF8StringEncoding error:&errMsg])
        {
            return NO;
        }
        NSString *strTitle=[self getCsvTitle];
        [self appendDataToFileWithString:strTitle withFilePath:strLogFilePath];//第一次创建时，增加每一列的标题
    }
    
    return YES;
}

- (BOOL)appendDataToFileWithString:(NSString *)string withFilePath:(NSString *)strFilePath
{
    NSFileHandle *myHandle = [NSFileHandle fileHandleForWritingAtPath:strFilePath];
    [myHandle seekToEndOfFile];
    [myHandle writeData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    [myHandle closeFile];
    
    return YES;
}
-(NSString *)getCsvTitle{
    NSString *fileName=@"TestPlan";
    NSString *rawfilePath=[[NSBundle mainBundle] resourcePath];
    rawfilePath=[rawfilePath stringByAppendingPathComponent:@"/securityFolder/"];
    NSString *fileSuffix=[NSString stringWithFormat:@"%@.csv",fileName];
    NSString *filePath=[rawfilePath stringByAppendingPathComponent:fileSuffix];
    NSLog(@"testplan:%@",filePath);
    
    CSVParser *parser=[CSVParser new];
    [parser openFile:filePath];
    NSMutableArray *csvContent = [parser parseFile];
    NSLog(@"%@", csvContent);
    [parser closeFile];
    //NSMutableArray *heading = [csvContent objectAtIndex:0];
    [csvContent removeObjectAtIndex:0];
    
    //NSArray *line=[csvContent objectAtIndex:0];
    //NSLog(@"%@", line);
    NSMutableArray *itemsData=[[NSMutableArray alloc] initWithCapacity:[csvContent count]];
    
    NSMutableArray *lowData=[[NSMutableArray alloc] initWithCapacity:[csvContent count]];
    NSMutableArray *upData=[[NSMutableArray alloc] initWithCapacity:[csvContent count]];
    NSMutableArray *unitData=[[NSMutableArray alloc] initWithCapacity:[csvContent count]];
    for (int index=0; index<[csvContent count]; index++) {
        NSArray *line=[csvContent objectAtIndex:index];
        //Test Data:     ||      TestPlan:
        [itemsData addObject:line[TP_TESTITEMS_INDEX]];
        [lowData addObject:line[TP_LOW_INDEX]];
        [upData addObject:line[TP_UP_INDEX]];
        [unitData addObject:line[TP_UNIT_INDEX]];
    }
    
    
    NSString *csvTitle = @"SN--->,Result,ErrorCode,TesterID,startTime,endTime,";
    for(NSString *item in itemsData){
        csvTitle = [csvTitle stringByAppendingString:item];
        csvTitle = [csvTitle stringByAppendingString:@","];
    }
    csvTitle = [csvTitle stringByAppendingString:@"\r\n"];
    csvTitle = [csvTitle stringByAppendingString:@"LowerLimit--->,,,,,,"];
    for(NSString *item in lowData){
        csvTitle = [csvTitle stringByAppendingString:item];
        csvTitle = [csvTitle stringByAppendingString:@","];
    }
    csvTitle = [csvTitle stringByAppendingString:@"\r\n"];
    csvTitle = [csvTitle stringByAppendingString:@"UpperLimit--->,,,,,,"];
    for(NSString *item in upData){
        csvTitle = [csvTitle stringByAppendingString:item];
        csvTitle = [csvTitle stringByAppendingString:@","];
    }
    csvTitle = [csvTitle stringByAppendingString:@"\r\n"];
    csvTitle = [csvTitle stringByAppendingString:@"MeasurementUnit--->,,,,,,"];
    for(NSString *item in unitData){
        csvTitle = [csvTitle stringByAppendingString:item];
        csvTitle = [csvTitle stringByAppendingString:@","];
    }
    csvTitle = [csvTitle stringByAppendingString:@"\r\n"];
    
    return csvTitle;
}
//2019_01
- (NSString *) getCurrentMonth
{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY_MM"];
    NSString *currentTime = [dateFormatter stringFromDate:today];
    return currentTime;
}
//2019_01_21
- (NSString *) getCurrentDate
{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY_MM_dd"];
    NSString *currentTime = [dateFormatter stringFromDate:today];
    return currentTime;
}
//2019_01_21_13
- (NSString *) getCurrentHour
{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY_MM_dd_HH"];
    NSString *currentTime = [dateFormatter stringFromDate:today];
    return currentTime;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}
//test timer track
-(void)testTimeTrack{
    int i=0;
    //通知主线程刷新
    dispatch_async(dispatch_get_main_queue(), ^{
        //回调或者说是通知主线程刷新，
        [self->_statusLabel setStringValue:[NSString stringWithFormat:@"Testing..."]];
        [self->_statusLabel setBackgroundColor:[NSColor systemYellowColor]];
    });
    while(_TESTING_FLAG)
    {
        NSLog(@"timer thread is still alive: %f(sec)", i*0.2);
        [NSThread sleepForTimeInterval:0.2];
        i++;
        //[durationCell setIntValue:i];
        //通知主线程刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            //回调或者说是通知主线程刷新，
            [self->_timerLabel setStringValue:[NSString stringWithFormat:@"%.2f s",i*0.2]];
        });
    }
    NSColor *color=[_TT_testResult isEqualToString:@"PASS"] ?
    [NSColor systemGreenColor] : [NSColor systemRedColor];
    //通知主线程刷新
    dispatch_async(dispatch_get_main_queue(), ^{
        //回调或者说是通知主线程刷新，
        //[self->_statusLabel setStringValue:[NSString stringWithFormat:@"Done"]];
        //[self->_statusLabel setBackgroundColor:[NSColor systemGreenColor]];
        [self updateYield:YES];
        [self->_snTF setStringValue:@""];
        [self->_snTF setEnabled:YES];
        [self->_startBtn setEnabled:YES];
        [self->_snTF becomeFirstResponder];
        [self->_statusLabel setStringValue:self->_TT_testResult];
        [self->_statusLabel setBackgroundColor:color];
        [self->_modeMenu setEnabled:YES];
        [self->_TTConfigBtn setEnabled:YES];
        [self->_clearBtn setEnabled:YES];
        //enable selectedBtn of every unit view
        for (int i=0; i<self->_UNIT_COUNT; i++) {
            UnitView *item=[self->_unitsArr objectAtIndex:i];
            [item._selectedBtn setEnabled:YES];
            [item._configBtn setEnabled:YES];
        }
    });
    //_SN_READY=NO;
    [self myPrintf:@"successfully finish main thread",@"\n[TAG]------Finish Test------\n\n",nil];
    
    //save LOG
    [self saveTTLog];
    
}
-(void)myPrintf:(NSString *)msg,...{
    NSString *result = msg;
    NSString *objStr;
    
    va_list arg_list;
    va_start(arg_list, msg);
    while ((objStr = va_arg(arg_list, NSString *))) {
        result = [result stringByAppendingString:objStr];
    }
    va_end(arg_list);
    
    NSString *string=[NSString stringWithFormat:@"[TT_ICT]:%@",result];
    [_ttLogView printTTLogString:string];
    
    NSLog(@"%@",string);
}

//alarm information display
-(long)alarmPanel:(NSString *)thisEnquire{
    NSLog(@"start run alarm window");
    NSAlert *theAlert=[[NSAlert alloc] init];
    [theAlert addButtonWithTitle:@"OK"]; //1000
    [theAlert setMessageText:@"Error!"];
    [theAlert setInformativeText:thisEnquire];
    [theAlert setAlertStyle:0];
    [theAlert setIcon:[NSImage imageNamed:@"Error_256px_5.png"]];
    NSLog(@"End run alarm window");
    return [theAlert runModal];
}
//right information display
-(long)rightPanel:(NSString *)thisEnquire{
    NSLog(@"start run right window");
    NSAlert *theAlert=[[NSAlert alloc] init];
    [theAlert addButtonWithTitle:@"OK"]; //1000
    [theAlert setMessageText:@"Successful!"];
    [theAlert setInformativeText:thisEnquire];
    [theAlert setAlertStyle:0];
    [theAlert setIcon:[NSImage imageNamed:@"Check_yes_256px.png"]];
    NSLog(@"End run right window");
    return [theAlert runModal];
}
//exit application
-(BOOL)windowShouldClose:(id)sender{
    [self myPrintf:@"window will close...",nil];
    
    _exitView=[[ExitView alloc] initWithNibName:@"ExitView" bundle:nil];
    _exitView.delegate=self;
    [_mainVC presentViewControllerAsModalWindow:_exitView];
    NSLog(@"show exit view done.");
    
    
    return NO;
}
//message from exit view
-(void)msgFromExitView:(NSString *)msg{
    [self myPrintf:@"msg:",msg,@" from exit view",nil];
    
    if ([msg isEqualToString:@"EXIT"]) {
        [self performSelectorInBackground:@selector(exitProgramThread) withObject:nil];
    }
    else{
        [_exitView closeView];
    }
}
-(void)exitProgramThread{
    [_exitView updateExitStatus:@"Init..." progressValue:10];
    for (int i=0; i<[_unitsArr count]; i++) {
        UnitView *item=[_unitsArr objectAtIndex:i];
        [item receiveTTdata:@"EXIT"];
    }
    [_exitView updateExitStatus:@"Send msg to slots...OK" progressValue:30];
    [NSThread sleepForTimeInterval:0.5];
    [_exitView updateExitStatus:@"Waiting for all slots close..." progressValue:70];
    int timeCount=0;
    while (timeCount < 100) {
        if (_FLAG_ALL_SLOT_EXIT_IS_OK) {
            break;
        }
        [NSThread sleepForTimeInterval:0.1];
        timeCount+=1;
    }
    [NSThread sleepForTimeInterval:0.5];
    [_exitView updateExitStatus:@"All slots close...OK" progressValue:90];
    [NSThread sleepForTimeInterval:0.5];
    //release ttConfig socket connect
    [_ttConfigView sendCmd:@"exit" TimeOut:2.0 withName:@"PYClient"];
    [NSThread sleepForTimeInterval:0.5];
    [_ttConfigView closeDevices];
    [_exitView updateExitStatus:@"TT devices close...OK" progressValue:90];
    [NSThread sleepForTimeInterval:0.5];
    
    [_exitView closeView];
    [NSApp terminate:self];
}
- (NSString *)cmdExe:(NSString *)cmd
{
    // 初始化并设置shell路径
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/bash"];
    // -c 用来执行string-commands（命令字符串），也就说不管后面的字符串里是什么都会被当做shellcode来执行
    NSArray *arguments = [NSArray arrayWithObjects: @"-c", cmd, nil];
    [task setArguments: arguments];
    
    // 新建输出管道作为Task的输出
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    NSPipe *pipe2=[NSPipe pipe];
    [task setStandardError:pipe2];
    
    // 开始task
    NSFileHandle *file = [pipe fileHandleForReading];
    NSFileHandle *file2 = [pipe2 fileHandleForReading];
    [task launch];
    [task waitUntilExit]; //执行结束后,得到执行的结果字符串++++++
    NSData *data;
    data = [file readDataToEndOfFile];
    NSString *result_str;
    NSString *error_str=[[NSString alloc] initWithData:[file2 readDataToEndOfFile] encoding:NSUTF8StringEncoding];
    if(![error_str isEqualToString:@""]) {
        //error_flag = true;
    }
    NSLog(@"error:%@",error_str);
    result_str = [[NSString alloc] initWithData: data encoding:NSUTF8StringEncoding]; //---------------------------------
    result_str=[result_str stringByAppendingString:error_str];
    return result_str;
}
-(void)syncEcecutePythonCmd:(NSString *)cmd{
    // 初始化并设置shell路径
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/bash"];
    // -c 用来执行string-commands（命令字符串），也就说不管后面的字符串里是什么都会被当做shellcode来执行
    NSArray *arguments = [NSArray arrayWithObjects: @"-c", cmd, nil];
    [task setArguments: arguments];
    
    [task launch];
}
@end
