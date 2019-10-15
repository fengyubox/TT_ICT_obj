//
//  DetailView.m
//  TT_ICT
//
//  Created by 曹伟东 on 2018/12/23.
//  Copyright © 2018年 曹伟东. All rights reserved.
//

#import "DetailView.h"
#import "MapIndex.h"

#define TV_COLUMN_COUNT     9 //TableView column count
/*Table Data Item Index*/
#define TV_ITEM_INDEX       0 //TableView test item name
#define TV_STATUS_INDEX     1
#define TV_VALUE_INDEX      2
#define TV_LOW_INDEX        3
#define TV_REFERENCE_INDEX  4
#define TV_UP_INDEX         5
#define TV_UNIT_INDEX       6
#define TV_DURATION_INDEX   7


@interface DetailView ()
//@interface DetailView ()<NSTableViewDelegate,NSTableViewDataSource>
@end

@implementation DetailView
{
    /*tableData[0]--Items
       tableData[1]--Status PASS/FAIL/SKIP/TEST...
       tableData[2]--Value
       tableData[3]--Low
       tableData[4]--Reference
       tableData[5]--Up
       tableData[6]--Unit
       tableData[7]--Duration
    */
    NSMutableArray *tableData[TV_COLUMN_COUNT-1];
    int rowRefresh;
    int testItemCount;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.

    [_testBtn setHidden:YES];
    NSString *titleStr=[NSString stringWithFormat:@"Slot-%d",self._id];
    [self setTitle:@""];
    [_titleLabel setStringValue:titleStr];
    //NSLog(@"detial view load...");
}

//更新tableview行颜色
- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell
   forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    if([tableData[TV_STATUS_INDEX] count]>rowIndex)
    {
        NSString *colorTag=[tableData[TV_STATUS_INDEX] objectAtIndex:rowIndex];
        if([colorTag isEqualToString:@"FAIL"])
        {
            [aCell setDrawsBackground:1];
            [aCell setBackgroundColor:[NSColor redColor]];
            
        }
        else if([colorTag isEqualToString:@"SKIP"])
        {
            
            [aCell setDrawsBackground:1];
            [aCell setBackgroundColor:[NSColor grayColor]];
            
        }
        else if([colorTag isEqualToString:@"PASS"])
        {
            
            [aCell setDrawsBackground:1];
            [aCell setBackgroundColor:[NSColor greenColor]];
            
        }
        else if([colorTag isEqualToString:@"TEST..."])
        {
            
            [aCell setDrawsBackground:1];
            [aCell setBackgroundColor:[NSColor yellowColor]];
            
        }
        else {
            [aCell setDrawsBackground:1];
            [aCell setBackgroundColor:[NSColor whiteColor]];
        }
    }
    else
    {
        [aCell setDrawsBackground:1];
        [aCell setBackgroundColor:[NSColor whiteColor]];
    }
}
//tableView datasource
- (NSInteger)numberOfRowsInTableView: (NSTableView *)aTableView
{
    return (int)[tableData[TV_ITEM_INDEX] count];
}
- (id)tableView: (NSTableView *)aTableView objectValueForTableColumn:
(NSTableColumn *)aTableColumn row: (NSInteger)rowIndex
{
    NSString *identifier=[aTableColumn identifier];
    
    if([identifier isEqualToString:@"No"]){
        return [NSString stringWithFormat:@"%ld",rowIndex+1];
    }
    else if([identifier isEqualToString:@"Items"]){
        return [tableData[TV_ITEM_INDEX] objectAtIndex:rowIndex];
        
    }
    else if([identifier isEqualToString:@"Status"]){
        
        int tt=(int)[tableData[TV_STATUS_INDEX] count];
        if(tt>rowIndex){
            return [tableData[TV_STATUS_INDEX] objectAtIndex:rowIndex];
            
        }
        else{
            return @"";
            
        }
        
        
    }
    else if([identifier isEqualToString:@"Value"]){
        
        int tt=(int)[tableData[TV_VALUE_INDEX] count];
        if(tt>rowIndex){
            return [tableData[TV_VALUE_INDEX] objectAtIndex:rowIndex];
            
        }
        else{
            return @"";
            
        }
        
        
    }
    else if([identifier isEqualToString:@"Low"]){
        return [tableData[TV_LOW_INDEX] objectAtIndex:rowIndex];
        
    }
    else if([identifier isEqualToString:@"Reference"]){
        return [tableData[TV_REFERENCE_INDEX] objectAtIndex:rowIndex];
        
    }
    else if([identifier isEqualToString:@"Up"]){
        return [tableData[TV_UP_INDEX] objectAtIndex:rowIndex];
        
    }
    else if([identifier isEqualToString:@"Unit"]){
        return [tableData[TV_UNIT_INDEX] objectAtIndex:rowIndex];
        
    }
    else if([identifier isEqualToString:@"Duration"]){
        int tt=(int)[tableData[TV_DURATION_INDEX] count];
        if(tt>rowIndex){
            return [tableData[TV_DURATION_INDEX] objectAtIndex:rowIndex];
            
        }
        else{
            return @"";
            
        }
    }
    else{
        
        return @"";
    }
    
}
//tableView 界面更新
-(void)updateTable{
    [_tableView scrollRowToVisible:rowRefresh];
    [_tableView display];
}
-(void)loadItems:(NSDictionary *)ts sortItems:(NSArray *)si{
    
    for (int i=0; i<testItemCount; i++) {
        id value;
        NSString *aa=[[NSString alloc] init];
        NSString* thisAttr=[si objectAtIndex:i];
        value=[ts objectForKey:thisAttr];
        
        aa=[value objectForKey:@"ItemName"];
        [tableData[0] addObject:aa];
        aa=[value objectForKey:@"LowerLimit"];
        [tableData[3] addObject:aa];
        aa=[value objectForKey:@"ReferValue"];
        [tableData[4] addObject:aa];
        aa=[value objectForKey:@"UpperLimit"];
        [tableData[5] addObject:aa];
        aa=[value objectForKey:@"MeasurementUnit"];
        [tableData[6] addObject:aa];
    }
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
    for(int i=0;i<TV_COLUMN_COUNT-1;i++){
        tableData[i]=[[NSMutableArray alloc] initWithCapacity:[csvContent count]];
    }
    for (int index=0; index<[csvContent count]; index++) {
        NSArray *line=[csvContent objectAtIndex:index];
        //Table Data:                ||      TestPlan:
        [tableData[TV_ITEM_INDEX] addObject:line[TP_TESTITEMS_INDEX]];
        [tableData[TV_LOW_INDEX] addObject:line[TP_LOW_INDEX]];
        [tableData[TV_REFERENCE_INDEX] addObject:line[TP_REFERENCE_INDEX]];
        [tableData[TV_UP_INDEX] addObject:line[TP_UP_INDEX]];
        [tableData[TV_UNIT_INDEX] addObject:line[TP_UNIT_INDEX]];
    }
    //NSLog(@"%@",_unitsData);
}
-(IBAction)backBtnAction:(id)sender{
    [self dismissViewController:self];
    self._isShowView=NO;
    [self myPrintf:@"Dismiss viewcontroller..."];
}

#pragma mark---Just for test tableview
-(IBAction)testBtnAction:(id)sender{
    [tableData[TV_STATUS_INDEX]  removeAllObjects];
    [tableData[TV_VALUE_INDEX]  removeAllObjects];
    [tableData[TV_DURATION_INDEX] removeAllObjects];
    rowRefresh=-1;
    [NSThread detachNewThreadSelector:@selector(testThread) toTarget:self withObject:nil];
}
-(void)testThread{
    for (int i=0; i<testItemCount; i++) {
        [self myPrintf:@"Test TableView..."];
        [tableData[1] addObject:@"TEST..."];
        rowRefresh++;
        [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:NO];
        [NSThread sleepForTimeInterval:0.05f];
        [tableData[2] addObject:@"value0101"];
        [tableData[1] replaceObjectAtIndex:i withObject:@"PASS"];
        [NSThread sleepForTimeInterval:0.1f];
        [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:NO];
    }
}

#pragma  mark-For UnitView.m update data
-(void)initDetailView{
    [self loadTestPlan];
    self._logString=@"";
}
-(void)resetTView{
    [tableData[TV_STATUS_INDEX]  removeAllObjects];
    [tableData[TV_VALUE_INDEX]  removeAllObjects];
    [tableData[TV_DURATION_INDEX] removeAllObjects];
    rowRefresh=-1;
}
-(void)updateTVWithTesting{
    rowRefresh++;
    [tableData[TV_STATUS_INDEX] addObject:@"TEST..."];
    if(!self._isShowView) return;
    [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:YES];
}
-(void)updateTVWithValue:(NSString *)value duration:(NSTimeInterval )dur result:(NSString *)result row:(int )index{
    [tableData[TV_VALUE_INDEX] addObject:value];
    [tableData[TV_STATUS_INDEX] replaceObjectAtIndex:index withObject:result];
    NSString *durStr=[NSString stringWithFormat:@"%f s",dur];
    [tableData[TV_DURATION_INDEX] addObject:durStr];
    if(!self._isShowView) return;
    [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:YES];
}
#pragma mark - log update
-(void)printLogString:(NSString *)log{
    [self performSelectorOnMainThread:@selector(logUpdate:) withObject:log waitUntilDone:YES];
}
-(void)logUpdate:(NSString *)txt{
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
        self._logString = [self._logString stringByAppendingString:txt];
        self._logString = [self._logString stringByAppendingString:@"\r\n"];
        if(self._isShowView){
            [self._logView setString:self._logString];
            [self._logView scrollRangeToVisible:NSMakeRange([[self._logView textStorage] length], 0)];
            [self._logView setNeedsDisplay:YES];
        }  
    }
}
-(void)viewWillDisappear{
    self._isShowView=NO;
    [self myPrintf:@"TableView will disappear..."];
}
-(void)myPrintf:(NSString *)msg{
    NSString *string=[NSString stringWithFormat:@"[Slot-%d TableView]:%@",self._id,msg];
    NSLog(@"%@",string);
}
@end
