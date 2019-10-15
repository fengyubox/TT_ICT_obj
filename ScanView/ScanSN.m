//
//  ScanSN.m
//  TT_ICT
//
//  Created by 曹伟东 on 2018/12/22.
//  Copyright © 2018年 曹伟东. All rights reserved.
//
#import "ScanSN.h"
//#define _UNIT_COUNT 4

@interface ScanSN ()
@property (nonatomic,strong) NSMutableDictionary *testSet;
@property (nonatomic,strong) NSMutableString *showSNs;
@property (nonatomic,strong) NSString *mesIP;
@property (nonatomic,strong) NSString *stationID;
@property (nonatomic,assign) int snCount;
@property (nonatomic,assign) BOOL ENTER_ESC;
@property (nonatomic,assign) int sn_length;

@end

@implementation ScanSN

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
}
-(void)viewWillAppear{
    _ENTER_ESC=NO;
    [self myPrintf:self._firstSN];
    _showSNs=[[NSMutableString alloc]initWithCapacity:1024];
    self._snArr =[[NSMutableArray alloc]initWithCapacity:1];
    _snCount=0;
    for (NSString *item in self._select_Slot_BoolArr) {
        _snCount+=1;
        [self myPrintf:item];
        if([item  isEqual: @"YES"]){
            [self._snArr addObject:self._firstSN];
            NSString *tempStr=[NSString stringWithFormat:@"%d.%@",_snCount,self._firstSN];
            [_showSNs appendString:tempStr];
            [_showSNs appendString:@"\r\n"];
            break;
        }
        [self._snArr addObject:@""];
        NSString *tempStr=[NSString stringWithFormat:@"%d.%@",_snCount,@"SKIP"];
        [_showSNs appendString:tempStr];
        [_showSNs appendString:@"\r\n"];
        
    }
    
    [_showSN_TF setStringValue:_showSNs];
    NSLog(@"%ld",[self._snArr count]);
}
-(void)initScanSnView{
    _testSet = [[NSMutableDictionary alloc] init];
    _testSet=[self._rootSet objectForKey:@"cfg"];
    _mesIP=[_testSet objectForKey:@"MESip"];
    _stationID=[_testSet objectForKey:@"StationID"];
    _sn_length=[[_testSet objectForKey:@"SNlength"] intValue];
}
-(IBAction)inputSNAction:(id)sender{
    if(_ENTER_ESC == YES) return;
    NSString *inputSN=[_inputSN_TF stringValue];
    [_inputSN_TF setStringValue:@""];
    [_inputSN_TF setEnabled:NO];
    if(![self SNisOK:inputSN]){
        [_inputSN_TF setEnabled:YES];
        [_inputSN_TF becomeFirstResponder];
        return;
    }
    NSString *tempStr=@"";
    //#1 selected slot "YES" ==>>inputSN
    bool find_YES_select=false;
    for (int i=_snCount; i<_UNIT_COUNT; i++) {
        if ([[self._select_Slot_BoolArr objectAtIndex:i] isEqual:@"YES"]) {
            if(find_YES_select) break;
            tempStr=[NSString stringWithFormat:@"%d.%@",_snCount+1,inputSN];
            [self._snArr addObject:inputSN];
            find_YES_select=true;
            _snCount+=1;
            //break;
        }else{
            tempStr=[NSString stringWithFormat:@"%d.%@",_snCount+1,@"SKIP"];
            [self._snArr addObject:@""];
            _snCount+=1;
        }
        
        [_showSNs appendString:tempStr];
        [_showSNs appendString:@"\r\n"];
        [_showSN_TF setStringValue:_showSNs];
        NSLog(@"snCount:%d",_snCount);
    }

    //_UNIT_COUNT=4
    if (_snCount == _UNIT_COUNT) {
        [self.delegate send2TT_SNs:self._snArr];
        [self dismissViewController:self];
    }
    
    [_inputSN_TF setEnabled:YES];
    [_inputSN_TF becomeFirstResponder];
}
//check SN is OK?
-(BOOL)SNisOK:(NSString *)sn{
    //check sn empty error
    if ([sn length] ==0) {
        [self alarmPanel:@"SN Empty Error!"];
        return NO;
    }
    //check sn repeat error
    if(self._snArr != nil && [self._snArr count]>0){
        for(NSString *item in self._snArr){
            if ([item isEqualToString:sn]){
                [self alarmPanel:@"SN Repeat Error!"];
                return NO;
            }
        }
    }
    //check test mode error
    if(self._isTestMode){
        //check sn length
        if ([sn length] != _sn_length) {
            [self alarmPanel:@"SN Length Error!"];
            return NO;
        }
        //check sn process
        //if(![self checkRouterWithSn:sn]) return NO;
    }
    //no error
    return YES;
}

-(IBAction)backBtnAction:(id)sender{
    _ENTER_ESC=YES;
    [self dismissViewController:self];
}
-(BOOL)checkRouterWithSn:(NSString *)strSn
{
    NSString *strMsg = @"";
    BOOL bResult = false;
    //第一步，创建URL
    NSString *strUrl = [NSString stringWithFormat:@"http://%@/bobcat/sfc_response.aspx", _mesIP];
    NSURL *url = [NSURL URLWithString:strUrl];
    //第二步，创建请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0f];
    [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
    NSString *strData = [NSString stringWithFormat:@"c=QUERY_RECORD&sn=%@&tsid=%@&p=UNIT_PROCESS_CHECK", strSn, _stationID];//设置参数
    //    NSString *strData = [NSString stringWithFormat:@"c=QUERY_RECORD&sn=C16C0708684&tsid=ITKS_A02-2FAP-01_3_CON-OQC&p=UNIT_PROCESS_CHECK"];//设置参数
    NSData *data = [strData dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    //第三步，连接服务器
    NSError *_Nullable errorWeb;
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&errorWeb];
    //0 SFC_OK  tsid::ITKS_A02-2FAP-01_3_CON-OQC::unit_process_check=UNIT OUT OF PROCESS ROUTE END
    NSString *strReceivedData = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    if(errorWeb != nil){
        NSString *errStr=[NSString stringWithFormat:@"%@",errorWeb];
        [self myPrintf:errStr];
        [self alarmPanel:errStr];
        return false;
    }
    
    NSString *strSubStr = @"unit_process_check=";
    if([strReceivedData containsString:strSubStr])
    {
        NSRange rang = [strReceivedData rangeOfString:strSubStr];
        strMsg = [strReceivedData substringFromIndex:(rang.location + rang.length)];
        if([strMsg isEqualToString:@"OK"])
        {
            bResult = true;
        }
        else
        {
            NSString *strErrMsg = @"";
            strSubStr = @"UNIT OUT OF PROCESS ";
            rang = [strMsg rangeOfString:strSubStr];
            strErrMsg = [strMsg substringFromIndex:(rang.location + rang.length)];
            [self alarmPanel:strErrMsg];
            bResult = false;
        }
    }
    else
    {
        NSString *dataStr=[NSString stringWithFormat:@"Bad receiveData:%@",strReceivedData];
        [self alarmPanel:dataStr];
        bResult = false;
    }
    
    return bResult;
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
-(void)myPrintf:(NSString *)msg{
    NSString *string=[NSString stringWithFormat:@"[ScanSN]:%@",msg];
    NSLog(@"%@",string);
}


- (void)send2TT_SNs:(NSObject *)message {
    [self myPrintf:@"la la la..."];
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
}

@end
