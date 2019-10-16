//
//  SubView2.m
//  layoutTest
//
//  Created by 曹伟东 on 2018/12/16.
//  Copyright © 2018年 曹伟东. All rights reserved.
//

#import "UnitView.h"
#import "MapIndex.h"

typedef NS_ENUM(NSInteger, ORSSerialRequestType) {
    ORSSerialRequestTypeMatchStr = 1,
    ORSSerialRequestTypeEndStr,
    ORSSerialRequestTypeReceivedStr,
    ORSSerialRequestTypeOther,
};

@interface UnitView ()
{
    //testplan data
    NSMutableArray *itemsData;
    NSMutableArray *groupData;
    NSMutableArray *funcData;
    NSMutableArray *commandsData;
    NSMutableArray *recSuffixData;
    NSMutableArray *valueTypeData;
    NSMutableArray *saveValueData;
    NSMutableArray *lowData;
    NSMutableArray *referValueData;
    NSMutableArray *upData;
    NSMutableArray *unitData;
    NSMutableArray *timeOutData;
    NSMutableArray *delayData;
    NSMutableArray *exitEnableData;
    NSMutableArray *skipData;
    NSMutableArray *pdcaFlag;
}
//For test config plist
@property (nonatomic,strong) NSMutableDictionary *testSet;
@property (nonatomic,strong) NSMutableDictionary *cfgSet;
@property (nonatomic,strong) NSString *snString;
@property (nonatomic,strong) NSString *testMode;
@property (nonatomic,strong) NSString *errorCode;

@property (nonatomic,assign) BOOL DUT_ISCONNECTED;
@property (nonatomic,assign) BOOL TASK_KEY_isOK;
@property (nonatomic,assign) BOOL SYNC_TASK_isDONE;
@property (nonatomic,strong) NSString *SYNC_TASK_RESULT;

@end

@implementation UnitView
//int standardTlen = 7; //(items)0001
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    _DUT_ISCONNECTED=NO;
    _TASK_KEY_isOK = NO;
    _SYNC_TASK_isDONE = NO;
    _SYNC_TASK_RESULT=@"NG";
    _snString=@"NA";
    //NSArray *baudRatesArray = @[@"9600", @"115200"];
    
    //load test plist
    [self initPlist];
    [self loadTestPlan];
    //init single slot TableView
    _detailView=[[DetailView alloc]initWithNibName:@"DetailView" bundle:nil];
    _detailView._id=self._id;
    [_detailView initDetailView];
    //set box background color
    self._box.contentView.wantsLayer = YES;
    self._box.contentView.layer.backgroundColor = [NSColor colorWithRed:0.0/255.0 green:191.0/255.0 blue:255.0/255.0 alpha:0.6].CGColor;
    [_progressIndicator1 setHidden:YES];
    
    //*************Config View**************************//
    _configView=[[myConfigView alloc] initWithNibName:@"ConfigView" bundle:nil];
    _configView.dictKey=[NSString stringWithFormat:@"Slot-%d",self._id];
    _configView.delegate=self;
    
    [_configView initView];
    //*****************End Config View******************//
    
    _pdca=[[InstantPudding alloc] init];
    
    _myProgressView = [[MyProgressView alloc] initWithFrame:CGRectMake(80, 10, 200, 70)];
    //[_myProgressView setFramBackground:[NSColor grayColor]];
    [self._box.contentView addSubview:_myProgressView];
    
    _testMode=@"TEST";
}
-(void)initPlist{
    _testSet = [[NSMutableDictionary alloc] init];
    _testSet=[self._rootSet objectForKey:@"testItems"];
}
-(void)loadTestPlan{
    NSString *fileName=@"TestPlan";
    NSString *rawfilePath=[[NSBundle mainBundle] resourcePath];
    rawfilePath=[rawfilePath stringByAppendingPathComponent:@"/securityFolder/"];
    NSString *fileSuffix=[NSString stringWithFormat:@"%@.csv",fileName];
    NSString *filePath=[rawfilePath stringByAppendingPathComponent:fileSuffix];
    NSLog(@"testplan:%@",filePath);
    
    CSVParser *parser=[CSVParser new];
    [parser openFile:filePath];
    NSMutableArray *csvContent = [parser parseFile];
    //NSLog(@"%@", csvContent);
    [parser closeFile];
    //NSMutableArray *heading = [csvContent objectAtIndex:0];
    [csvContent removeObjectAtIndex:0];
    
    //NSArray *line=[csvContent objectAtIndex:0];
    //NSLog(@"%@", line);
    itemsData=[[NSMutableArray alloc] initWithCapacity:[csvContent count]];
    groupData=[[NSMutableArray alloc] initWithCapacity:[csvContent count]];
    funcData=[[NSMutableArray alloc] initWithCapacity:[csvContent count]];
    commandsData=[[NSMutableArray alloc] initWithCapacity:[csvContent count]];
    recSuffixData=[[NSMutableArray alloc] initWithCapacity:[csvContent count]];
    valueTypeData=[[NSMutableArray alloc] initWithCapacity:[csvContent count]];
    saveValueData=[[NSMutableArray alloc] initWithCapacity:[csvContent count]];
    lowData=[[NSMutableArray alloc] initWithCapacity:[csvContent count]];
    referValueData=[[NSMutableArray alloc] initWithCapacity:[csvContent count]];
    upData=[[NSMutableArray alloc] initWithCapacity:[csvContent count]];
    unitData=[[NSMutableArray alloc] initWithCapacity:[csvContent count]];
    timeOutData=[[NSMutableArray alloc] initWithCapacity:[csvContent count]];
    delayData=[[NSMutableArray alloc] initWithCapacity:[csvContent count]];
    exitEnableData=[[NSMutableArray alloc] initWithCapacity:[csvContent count]];
    skipData=[[NSMutableArray alloc] initWithCapacity:[csvContent count]];
    pdcaFlag=[[NSMutableArray alloc] initWithCapacity:[csvContent count]];
    
    for (int index=0; index<[csvContent count]; index++) {
        NSArray *line=[csvContent objectAtIndex:index];
        //Test Data:     ||      TestPlan:
        [itemsData addObject:line[TP_TESTITEMS_INDEX]];
        [groupData addObject:line[TP_GROUP_INDEX]];
        [funcData addObject:line[TP_FUNC_INDEX]];
        [commandsData addObject:line[TP_CMD_INDEX]];
        [recSuffixData addObject:line[TP_RECSUF_INDEX]];
        [valueTypeData addObject:line[TP_VALTYP_INDEX]];
        [saveValueData addObject:line[TP_VALSAV_INDEX]];
        [lowData addObject:line[TP_LOW_INDEX]];
        [referValueData addObject:line[TP_REFERENCE_INDEX]];
        [upData addObject:line[TP_UP_INDEX]];
        [unitData addObject:line[TP_UNIT_INDEX]];
        [timeOutData addObject:line[TP_TIMEOUT_INDEX]];
        [delayData addObject:line[TP_DELAY_INDEX]];
        [exitEnableData addObject:line[TP_EXITENABLE_INDEX]];
        [skipData addObject:line[TP_SKIP_INDEX]];
        [pdcaFlag addObject:line[TP_PDCA_INDEX]];
    }
}
-(NSString *)getCsvTitle{
    
    
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
//message from Config View
- (void)msgFromConfigView:(NSString *)msg {
    NSString *log=[NSString stringWithFormat:@"msg:%@ from config view",msg];
    [self myPrintf:log];
    //DUT connect status:"STATUS:0"
    if ([msg hasPrefix:@"STATUS"]) {
        NSArray *tempArr=[msg componentsSeparatedByString:@":"];
        _DUT_ISCONNECTED=[tempArr[1] boolValue];
        if (!_DUT_ISCONNECTED) {
            [self._callDetialBtn setTitle:@"Error"];
            self._box.contentView.layer.backgroundColor = [NSColor colorWithRed:220.0/255.0 green:20.0/255.0 blue:60.0/255.0 alpha:0.8].CGColor;
        }else{
            [self._callDetialBtn setTitle:@"Ready"];
            self._box.contentView.layer.backgroundColor = [NSColor colorWithRed:0.0/255.0 green:191.0/255.0 blue:255.0/255.0 alpha:0.6].CGColor;
        }
    }
}
//received data from ConfigView serialport
//-(void)serialReceivedData:(NSString *)data{
//    
//}
//send data to TT
-(void)sendTestThread{
    NSString *msg=[NSString stringWithFormat:@"Hello,myID:%d",self._id];
    [self myPrintf:msg];
    [self.delegate send2TTdata:msg];
}
//receive data from TT
-(void)receiveTTdata:(NSString *)data{
    NSString *msg = [NSString stringWithFormat:@"receive from TT:%@",data];
    [self myPrintf:msg];
    //analysis receive command form TT
    if([data hasPrefix:@"SN:"]){ //get sn of unit
        _detailView._logString=@"";
        
        self._box.contentView.layer.backgroundColor = [NSColor colorWithRed:0.0/255.0 green:191.0/255.0 blue:255.0/255.0 alpha:0.6].CGColor;
        NSString *sn=[data substringFromIndex:3];
        _snString=sn; //save SN string
        [_snLabel setStringValue:sn];
        if ([sn length] == 0) {
            self._box.contentView.layer.backgroundColor = [NSColor colorWithRed:238.0/255.0 green:130.0/255.0 blue:238.0/255.0 alpha:0.6].CGColor;
            [self._callDetialBtn setEnabled:NO];
            [self._callDetialBtn setTitle:@"IDLE"];
        }else{
            [self._callDetialBtn setEnabled:YES];
            [self._callDetialBtn setTitle:@"Ready"];
            [_detailView resetTView];
        }
    }else if([data hasPrefix:@"MODE:"]){
        NSString *modeStr=[data substringFromIndex:5];
        _testMode=modeStr;
        [self setMode:modeStr];
    }
    else if([data isEqualToString:@"TASK_KEY_IS_OK"]){
        _TASK_KEY_isOK = YES;
    }
    //"SYNC_TASK_DONE"
    else if([data hasPrefix:@"SYNC_TASK_DONE"]){
        _SYNC_TASK_RESULT = [data componentsSeparatedByString:@"#"][1];
        _SYNC_TASK_isDONE = YES;
    }
    else if([data isEqual:@"START"]){ //start testing
        
        [self myPrintf:@"-----TEST START-----"];
        //[_progressIndicator1 setHidden:NO];
        
        self._box.contentView.layer.backgroundColor = [NSColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:0.0/255.0 alpha:0.6].CGColor;
        //[_progressIndicator1 startAnimation:nil];
        [_myProgressView showWaitingWithsQuareColor:[NSColor lightGrayColor] side:20 speed:0.5];
        
        [self._callDetialBtn setTitle:@"Testing"];
        [NSThread detachNewThreadSelector:@selector(mainTestFunc) toTarget:self withObject:nil];
    }else if([data isEqualToString:@"EXIT"]){//exit app
        [_configView closeDevices];
        [self.delegate send2TTdata:@"EXIT,OK"];
    }
    
}
//"TEST"--Test Mode "DEBUG"--Debug Mode
-(void)setMode:(NSString *)mode{
    BOOL hideB=YES;
    if ([mode isEqualToString:@"DEBUG"]) hideB=NO;
    [self._configBtn setHidden:hideB];
    
}
//present DetailView
-(IBAction)callDetailAction:(id)sender{
    _detailView._isShowView = YES;
    [_detailView.view setFrameSize:NSMakeSize(900, 700)];
    [self presentViewControllerAsModalWindow:_detailView];
    [self myPrintf:@"present DetailView..."];
}
//present ConfigView
-(IBAction)configBtnAction:(id)sender{
    [self presentViewControllerAsModalWindow:_configView];
    [self myPrintf:@"present ConfigView..."];
}
//refresh detail TableView data
-(void)performTestProgram:(bool *)testResult{
    [_detailView resetTView];
    [self myPrintf:[NSString stringWithFormat:@"SN:%@",_snString]];
    if (_DUT_ISCONNECTED) {
        [self myPrintf:@"Ready,begin testing..."];
    }else{
        [self myPrintf:@"SerialPort Close,stop testing!"];
        *testResult=false;
        return;
    }
    NSString *resultStr=@"PASS";
    NSString *startTime=[self getCurrentTimeStr];
    NSString *csvData=[NSString stringWithFormat:@"CSVDATA#%@,",_snString];
    NSString *recData=@"";
    _errorCode=@"";
    
    
    NSString *_Feedback=@"";
    for (int i=0; i<[itemsData count]; i++) {
        _TASK_KEY_isOK = NO;
        _SYNC_TASK_isDONE = NO;
        _SYNC_TASK_RESULT = @"NG";
        
        NSDate *t1=[NSDate date];
        [_detailView updateTVWithTesting];
        [self myPrintf:@"========================================="];
        [NSThread sleepForTimeInterval:0.01f];
        NSString *thisItem=[itemsData objectAtIndex:i];
        NSString *msg =[NSString stringWithFormat:@"Item:%@",thisItem];
        [self myPrintf:msg];
        NSString *thisTag=[groupData objectAtIndex:i];
        NSString *thisConnecter=[funcData objectAtIndex:i];
        NSString *thisCommand=[commandsData objectAtIndex:i];
        NSString *thisJudgeStyle=[valueTypeData objectAtIndex:i];
        NSString *thisResponse=[referValueData objectAtIndex:i];
        NSString *thisLowLimit=[lowData objectAtIndex:i];
        NSString *thisRefValue=[referValueData objectAtIndex:i];
        NSString *thisUpLimit=[upData objectAtIndex:i];
        NSString *thisUnit=[unitData objectAtIndex:i];
        
        float thisTimeOut=[[timeOutData objectAtIndex:i] floatValue];
        float thisDelay=[[delayData objectAtIndex:i] floatValue];
        BOOL isSkiped=[[skipData objectAtIndex:i] boolValue];
        
        msg=[NSString stringWithFormat:@"send:%@",thisCommand];
        [self myPrintf:msg];
        NSString *thisStatus=@""; //TableView--Status column
        NSString *thisValue=@"";  //TableView--Value column
        
        if (isSkiped) { //SKIP
            _Feedback=@"skip";
            thisStatus=@"SKIP";
            thisValue=@"skip";
        }else if([thisConnecter isEqualToString:@"connectFIX"]){
            //
            thisValue=[_configView sendCmd:thisCommand TimeOut:thisTimeOut withName:@"DUT"];
            
            if ([thisJudgeStyle isEqualToString:@"string"]) {
                //NSString *matchStr=[thisJudgeStyle substringFromIndex:9];
                if ([thisValue containsString:thisResponse]) {
                    thisStatus=@"PASS";
                }else{
                    thisStatus=@"FAIL";
                    *testResult=false;
                }
            }else{ //valueCheck
                //storage receive string for 'feedback'
                if([thisCommand containsString:@"FETC?"]){
                    thisStatus=@"PASS";
                    _Feedback=thisValue;
                }
            }
            
        }else if([thisConnecter isEqualToString:@"feedback"]){
            //+9.10000000E+37,+9.20000000E+37,+9.30000000E+37,+9.40000000E+37,+9.50000000E+37
            NSArray *feedbackArr=[_Feedback componentsSeparatedByString:@","];
            int index=[thisCommand intValue]-1;
            
            if (index<[feedbackArr count]) {
                thisValue=[feedbackArr objectAtIndex:index];
                if ([self judgeValue:thisValue low:thisLowLimit up:thisUpLimit]) {
                    thisStatus=@"PASS";
                }else{
                    thisStatus=@"FAIL";
                }
            }else{
                thisValue=@"NA";
                thisStatus=@"FAIL";
            }
            
            
        }else if([thisConnecter isEqualToString:@"connectREAD"]){
            //readStep;55*_* --testTag:STEP
            //readTmp;35.67C*_* --testTag:TMP
            //readVolt1;4.86V*_* --testTag:VOLT
            
            thisValue=[_configView sendCmd:thisCommand TimeOut:thisTimeOut withName:@"DUT"];
            if(![thisValue isEqualToString:@"TIMEOUT"]) {
                NSArray *tempArr=[thisValue componentsSeparatedByString:@"_"];
                NSInteger len=0;
                if ([thisTag isEqualToString:@"STEP"]) {
                    len=[tempArr[0] length]-1;
                }else{
                    len=[tempArr[0] length]-2;
                }
                if (len < 1) {
                    thisStatus=@"FAIL";
                }else{
                    NSString *tempValue=[tempArr[0] substringWithRange:NSMakeRange(0, len)];
                    thisValue=tempValue;
                    if ([self judgeValue:thisValue low:thisLowLimit up:thisUpLimit]) {
                        thisStatus=@"PASS";
                    }else{
                        thisStatus=@"FAIL";
                    }
                }
                
            }else{
                thisValue=@"TimeOut";
                thisStatus=@"FAIL";
                *testResult=false;
            }
        }
        //serial execute task in every unit
        else if([thisConnecter isEqualToString:@"serialTask"]){
            BOOL KEY_isOK = NO;
            NSString *cmd=[NSString stringWithFormat:@"GetKEY:%d",self._id-1];
            int get_count=0;
            while (NO == KEY_isOK) {
                [self.delegate send2TTdata:cmd];
                [NSThread sleepForTimeInterval:0.01];
                if (YES == _TASK_KEY_isOK) {
                    KEY_isOK = YES;
                    break;
                }
                [NSThread sleepForTimeInterval:0.5];
                get_count +=1;
                if (500 == get_count) {
                    [self myPrintf:@"ERROR:get task key timeout!"];
                    break;
                }
            }
            if (YES == KEY_isOK) {
                //this function in sub thread,so call UI need in main thread
                //[self performSelectorOnMainThread:@selector(showDialog:) withObject:thisCommand waitUntilDone:YES];
                [self myPrintf:@"Serial task done."];
                thisValue=@"OK";
                thisStatus=@"PASS";
                [self.delegate send2TTdata:@"ReturnKEY"];
                _TASK_KEY_isOK = NO;
            }else{
                thisValue=@"TimeOut";
                thisStatus=@"FAIL";
                *testResult=false;
            }
        }
        //all unit sync to execute a task
        else if([thisConnecter isEqualToString:@"syncTask"]){
            NSString *cmd=[NSString stringWithFormat:@"RequestSyncTask#%@",thisCommand];
            [self.delegate send2TTdata:cmd];
            BOOL TASK_DONE = NO;
            int get_count = 0;
            while (NO == TASK_DONE) {
                if (YES == _SYNC_TASK_isDONE) {
                    TASK_DONE = YES;
                    break;
                }
                [NSThread sleepForTimeInterval:1.0];
                get_count +=1;
                if (200 == get_count) {
                    [self myPrintf:@"ERROR:sync timeout!"];
                    break;
                }
            }
            if (YES == TASK_DONE ) {
                thisValue=_SYNC_TASK_RESULT;
                if ([thisValue isEqualToString:thisResponse]) {
                    thisStatus=@"PASS";
                }else{
                    thisStatus=@"FAIL";
                }
            }else{
                thisValue=@"TimeOut";
                thisStatus=@"FAIL";
                *testResult=false;
            }
        }
        else{ //valid test connecter
            thisStatus=@"FAIL";
            thisValue=@"!connecter error!";
            [self myPrintf:@"!connecter error!"];
        }
        
        msg=[NSString stringWithFormat:@"value:%@ up:%@ ref:%@ low:%@ unit:%@ result:%@",
             thisValue,thisUpLimit,thisRefValue,thisLowLimit,thisUnit,thisStatus];
        [self myPrintf:msg];
        NSDate *t2=[NSDate date];
        NSTimeInterval timer=[t2 timeIntervalSinceDate:t1];
        msg=[NSString stringWithFormat:@"duration:%f s",timer];
        [self myPrintf:msg];
        [NSThread sleepForTimeInterval:0.02f];
        
        thisValue=[thisValue stringByReplacingOccurrencesOfString:@"#" withString:@"@"];
        thisValue=[thisValue stringByReplacingOccurrencesOfString:@"," withString:@"@"];
        thisValue=[thisValue stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
        thisValue=[thisValue stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        thisValue=[thisValue stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        //value-Status as: 12.23V PASS/FAIL/SKIP
        [_detailView updateTVWithValue:thisValue duration:timer result:thisStatus row:i];
        
        
        recData=[recData stringByAppendingString:thisValue];
        recData=[recData stringByAppendingString:@","];
        
        if ([thisStatus isEqualToString:@"FAIL"] && [_errorCode isEqualToString:@""]) {
            _errorCode=[NSString stringWithFormat:@"EC_%d",i+1];
            resultStr=@"FAIL";
        }
        
        [NSThread sleepForTimeInterval:thisDelay];
    }
    
    //send csvdata to TTView
    NSString *testerID=[NSString stringWithFormat:@"%d,",self._id];
    NSString *endTime=[self getCurrentTimeStr];
    csvData=[csvData stringByAppendingString:resultStr];
    csvData=[csvData stringByAppendingString:@","];
    csvData=[csvData stringByAppendingString:_errorCode];
    csvData=[csvData stringByAppendingString:@","];
    csvData=[csvData stringByAppendingString:testerID];
    csvData=[csvData stringByAppendingString:startTime];
    csvData=[csvData stringByAppendingString:@","];
    csvData=[csvData stringByAppendingString:endTime];
    csvData=[csvData stringByAppendingString:@","];
    csvData=[csvData stringByAppendingString:recData];
    csvData=[csvData stringByAppendingString:@"\r\n"];
    //csvData:CSVDATA#SN001,PASS,,...
    [self.delegate send2TTdata:csvData];
    
    //update PDCA
    if (self._pdcaEnable && [_testMode isEqualToString:@"TEST"]) {
        NSArray *valuesArr=[recData componentsSeparatedByString:@","];
        BOOL status=[self updatePDCAaction:valuesArr];
        [self myPrintf:[NSString stringWithFormat:@"updatePDCA status:%hhd",status]];
        if (!status) {
            [self alarmPanel:@"Update PDCA error!"];
        }
    }
    
    *testResult= [resultStr isEqualToString:@"PASS"] ? true:false;
}
-(bool)judgeValue:(NSString *)value low:(NSString *)lowLimit up:(NSString *)upLimit{
    bool bResult=false;
    float valueFloat=[value floatValue];
//    if ([value containsString:@"E"]) { //science number
//        valueFloat=[self science2float:value];
//    }else{
//        valueFloat=[value floatValue];
//    }
    if ([lowLimit length]>0 && [upLimit length]>0) {
        float lowFloat=[lowLimit floatValue];
        float upFloat=[upLimit floatValue];
        if (valueFloat >= lowFloat && valueFloat <= upFloat) {
            bResult = true;
        }
    }else if([lowLimit length] == 0 && [upLimit length]>0){
        float upFloat=[upLimit floatValue];
        if(valueFloat <= upFloat) bResult=true;
    }else if([lowLimit length]>0 && [upLimit length] == 0){
        float lowFloat=[lowLimit floatValue];
        if(valueFloat >= lowFloat) bResult=true;
    }else if([lowLimit length]==0 && [upLimit length] == 0){
        bResult=true;
    }
    
    return bResult;
}

-(IBAction)SelectedBtnAction:(id)sender{
    if ([self._selectedBtn state]) {
        NSString *msg=[NSString stringWithFormat:@"Selected:%d:%d",self._id,1];
        [self.delegate send2TTdata:msg];
        [self._callDetialBtn setHidden:NO];
        //[_progressIndicator1 setHidden:NO];
        [_snLabel setStringValue:@"NA"];
        [self._callDetialBtn setTitle:@"Ready"];
        [_detailView resetTView];
        self._box.contentView.layer.backgroundColor = [NSColor colorWithRed:0.0/255.0 green:191.0/255.0 blue:255.0/255.0 alpha:0.6].CGColor;
    }else{
        NSString *msg=[NSString stringWithFormat:@"Selected:%d:%d",self._id,0];
        [self.delegate send2TTdata:msg];
        [self._callDetialBtn setHidden:YES];
        //[_progressIndicator1 setHidden:YES];
        [_snLabel setStringValue:@""];
        self._box.contentView.layer.backgroundColor = [NSColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:0.7].CGColor;
    }
}
#pragma mark - main test function Methods
-(void)mainTestFunc{
    bool _test_resut=true;
    //test program
    [self performTestProgram:&_test_resut];
    
    //send "Finish" to TT
    NSString *resultStr=_errorCode;
    if(_test_resut) resultStr=@"PASS";
    if([_testMode isEqualToString:@"TEST"]) [self update2MESWithResult:resultStr];
    [self myPrintf:@"-----TEST END-----"];
    
    NSString *msg=[NSString stringWithFormat:@"Finish:%d:%@",self._id,resultStr];
    [self myPrintf:msg];
    //save location log
    [self saveSlotLog];
    [NSThread sleepForTimeInterval:0.05f];
    
    [self.delegate send2TTdata:msg];
    //通知主线程刷新
    dispatch_async(dispatch_get_main_queue(), ^{
        //回调或者说是通知主线程刷新，
        //[self->_progressIndicator1 stopAnimation:nil];
        //[self->_progressIndicator1 setHidden:YES];
        [self->_myProgressView toDisappear:NO];
        if (_test_resut) {  //test result :PASS
            [self._callDetialBtn setTitle:@"PASS"];
            self._box.contentView.layer.backgroundColor = [NSColor colorWithRed:127.0/255.0 green:255.0/255.0 blue:0.0/255.0 alpha:0.8].CGColor;
        }else{ //test result :FAIL
            [self._callDetialBtn setTitle:self->_errorCode];
            self._box.contentView.layer.backgroundColor = [NSColor colorWithRed:220.0/255.0 green:20.0/255.0 blue:60.0/255.0 alpha:0.8].CGColor;
        }
    });
}


-(void)myPrintf:(NSString *)msg{
    msg=[msg stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];
    [_detailView printLogString:msg];
    NSString *string=[NSString stringWithFormat:@"[Slot-%d UnitView]:%@",self._id,msg];
    NSLog(@"%@",string);
}
- (void)send2TTdata:(NSString *)data {
    NSLog(@"la la la...");
}
//alarm information display
-(long)alarmPanel:(NSString *)thisEnquire{
    NSString *msg=[NSString stringWithFormat:@"Alarm:%@",thisEnquire];
    [self myPrintf:msg];
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
    NSString *msg=[NSString stringWithFormat:@"Right:%@",thisEnquire];
    [self myPrintf:msg];
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
//show question dialog
-(long)showDialog:(NSString *)question{
    NSString *msg=[NSString stringWithFormat:@"dialog question:%@",question];
    [self myPrintf:msg];
    NSLog(@"start run dialog window");
    NSAlert *theAlert=[[NSAlert alloc] init];
    [theAlert addButtonWithTitle:@"OK"]; //1000
    NSString *title=[NSString stringWithFormat:@"[Slot-%d]Question:",self._id];
    [theAlert setMessageText:title];
    [theAlert setInformativeText:question];
    [theAlert setAlertStyle:0];
    [theAlert setIcon:[NSImage imageNamed:@"question1.png"]];
    NSLog(@"End run dialog window");
    return [theAlert runModal];
}
-(void)update2MESWithResult:(NSString *)result
{
    _testSet=[self._rootSet objectForKey:@"cfg"];
    NSString *productName=[_testSet objectForKey:@"ProductName"];
    NSString *mesIP=[_testSet objectForKey:@"MESip"];
    NSString *stationID=[_testSet objectForKey:@"StationID"];
    
    //第一步，创建URL
    //FWY7052009VG64412  192.168.4.17  172.17.32.16
    NSString *strUrl = [NSString stringWithFormat:@"http://%@/bobcat/sfc_response.aspx", mesIP];
    NSURL *url = [NSURL URLWithString:strUrl];
    //第二步，创建请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0f];
    [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
    //result=PASS&c=ADD_RECORD&product=B188&test_station_name=SA-QT2&station_id=ITKS_A02-3FAP-05_1_CHECK-SN&start_time=2017-07-10+14%3a58%3a39&sn=DLC72760118FKVPAP
    NSString *startTime=[self getCurrentTime];
    NSString *strData = [NSString stringWithFormat:@"result=%@&c=ADD_RECORD&product=%@&test_station_name=CheckSn&station_id=%@&start_time=%@&sn=%@", result, productName, stationID,startTime, _snString];//设置参数
    
    NSData *data = [strData dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    //第三步，连接服务器
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    //0 SFC_OK
    NSString *strReceivedData = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    NSString *msg=[NSString stringWithFormat:@"Add Data to MES:%@", strReceivedData];
    [self myPrintf:msg];
    if(![strReceivedData containsString:@"SFC_OK"]){
        [self alarmPanel:[NSString stringWithFormat:@"Update to MES fail:\r\n %@",strReceivedData]];
    }
}
- (NSString *)getCurrentTime
{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    [dateFormatter setDateFormat:@"YYYY_MM_dd_HH:mm:ss"];
    [dateFormatter setDateFormat:@"YYYY.MM.dd HH:mm:ss"];
    NSString *currentTime = [dateFormatter stringFromDate:today];
    return currentTime;
}
-(NSString *)getCurrentTimeStr{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    [dateFormatter setDateFormat:@"YYYY_MM_dd_HH:mm:ss"];
    [dateFormatter setDateFormat:@"YYYY/MM/dd HH:mm:ss"];
    NSString *currentTime = [dateFormatter stringFromDate:today];
    return currentTime;
}
-(float )science2float:(NSString *)inputStr{
    if(![inputStr containsString:@"E"]) return 0.00;
    float result =0.00;
    //NSString *txt = @"+6.3746829E-07";
    inputStr=[inputStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    inputStr=[inputStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    inputStr=[inputStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    inputStr=[inputStr stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    NSRange range =[inputStr rangeOfString:@"E"];
    NSInteger Elocation = range.location;
    if(Elocation != 11) return 0.00;
    //NSLog(@"Elocation:%ld",(long)Elocation);
    //+6.37468290
    NSString *str1 = [inputStr substringToIndex:Elocation];
    //NSLog(@"str1:%@",str1);
    NSString *aStr = [str1 substringFromIndex:1];
    //NSLog(@"aStr:%@",aStr);
    float afloat = [aStr floatValue];
    //NSLog(@"afloat:%f",afloat);
    //if([str1 hasPrefix:@"-"]) afloat = 0 - afloat;
    //NSLog(@"afloat:(+-):%f",afloat);
    //+10
    NSString *str2 = [inputStr substringFromIndex:(Elocation+1)];
    //NSLog(@"str2:%@",str2);
    NSInteger bInt = [str2 integerValue];
    //NSLog(@"bInt:%ld",(long)bInt);
    result = afloat * (pow(10,bInt));
    //NSLog(@"result:%f",result);
    //outputStr = [NSString stringWithFormat:@"%f",result];
    return result;
}

//Save location TT_log in log.txt
-(void)saveSlotLog{
    NSString *strMonth = [self getCurrentMonth];
    _testSet=[self._rootSet objectForKey:@"cfg"];
    NSString *_swName=[_testSet objectForKey:@"SWname"];
    NSString *logPath = [NSString stringWithFormat:@"/vault/%@/%@/Slot_log/Slot-%d",_swName,strMonth,self._id];
    NSString *strCurrentTime = [self getCurrentTimeSuffix];
    NSString *strFileName = [NSString stringWithFormat:@"%@_%@_%@.txt", _snString,strCurrentTime,_testMode];
    
    NSString *strFilePath = [NSString stringWithFormat:@"%@/%@", logPath, strFileName];
    
    if(YES == [self createLOGFileWithPath:logPath withFilePath:strFilePath])
    {
        [self appendDataToFileWithString:[_detailView _logString] withFilePath:strFilePath];
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
        [self appendDataToFileWithString:@"----NEW SLOT LOG----\r\n" withFilePath:strLogFilePath];//第一次创建时，增加INFO
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
//20190121101245342
-(NSString *)getCurrentTimeSuffix{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYYMMddHHmmssSSS"];
    NSString *currentTime = [dateFormatter stringFromDate:today];
    return currentTime;
}
//update PDCA action
-(BOOL)updatePDCAaction:(NSArray *)values
{
    NSString *_errMsg=@"NA";
    NSString *version=[_pdca GetIPVersion];
    NSLog(@"InstantPudding vers:%@",version);
    
    if (NO == [_pdca IPStart])
    {
        _errMsg = @"IPStart error";
        NSLog(@"pdca net error");
        return NO;
    }
    NSLog(@"IPStart1 ok");
    
    NSString *SN=@"YM123456789";
    if (NO == [_pdca ValidateSerialNumber:SN])
    {
        _errMsg=@"Validate SN error";
        NSLog(@"pdca sn error");
        return NO;
    }
    /*
     NSLog(@"Validate SN ok");
     if(NO ==[_pdca IPamIOkay:SN])
     {
     NSLog(@"IPamIOKay error");
     return false;
     }
     NSLog(@"IPamIOKay done");
     */
    if (NO == [_pdca AddIPAttribute:@"serialnumber" Value:SN]) {
        _errMsg=@"Add SN error";
        NSLog(@"SN error");
        return NO;
    }
    NSLog(@"AddIPAttribute SN ok");
    
    if(NO == [_pdca AddIPAttribute:@"softwarename" Value:@"Pudding"])
    {
        _errMsg=@"Add softwarename error";
        NSLog(@"softwarename error");
        return NO;
    }
    NSLog(@"AddIPAttribute software ok");
    
    //NSString *_swVersion=@"1.0.0";
    if(NO == [_pdca AddIPAttribute:@"softwareversion" Value:@"1.1.93"])
    {
        _errMsg=@"Add softwareversion error";
        NSLog(@"softwareversion error");
        return NO;
    }
    NSLog(@"AddIPAttribute softwareversion ok");
    /*
     //update testitem value
     if(false == [_pdca AddIPTestItem:strName TestValue:strValue LowerLimit:strLowerLimit UpperLimit:strUpperLimit Priority:IP_PRIORITY_REALTIME_WITH_ALARMS Units:strUnit])
     {
     return false;
     }
     */
    //-----------------updte all testitem value----------------------------------
    /*
     for (int i=0; i<[_itemsData count]; i++){
     if ([_pdcaFlag[i] boolValue]) {
     NSString *valueType=_valueTypeData[i];
     NSString *testItem=_itemsData[i];
     NSString *strValue=values[i];
     NSString *low=_lowData[i];
     NSString *up=_upData[i];
     NSString *unit=_unitData[i];
     
     NSString *msg=[NSString stringWithFormat:@"value type:%@ value:%@",valueType,strValue];
     [self myPrintf:msg];
     if ([valueType isEqualToString:@"value"]) {
     if(false == [_pdca AddIPTestItem:testItem TestValue:strValue LowerLimit:low UpperLimit:up Priority:IP_PRIORITY_REALTIME_WITH_ALARMS Units:unit])
     {
     [self myPrintf:@"AddIPTestItem error"];
     return NO;
     }
     }
     else if ([valueType isEqualToString:@"string"])
     {
     if(NO == [_pdca AddIPAttribute:testItem Value:strValue])
     {
     NSLog(@"AddIPAttribute error");
     return NO;
     }
     }
     else
     {
     [self myPrintf:@"unknow type of value"];
     }
     }
     }
     */
    //-----------------------------------------------------------------------------------
    /*
     //update log file to PDCA
     if(NO ==[_pdca addBlobFile:_swName logFileName:strFileName])
     {
     _errMsg=@"sendLog2PDCA error";
     NSLog(@"sendLog2PDCA error");
     return false;
     }
     */
    BOOL bResult = NO;
    [_pdca IPDoneWithResult:bResult];
    
    NSLog(@"pdca done");
    
    return YES;
}


@end
