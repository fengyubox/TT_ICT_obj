//
//  MyProgressView.h
//  PrograssBarTest
//
//  Created by Weidong Cao on 2019/9/26.
//  Copyright © 2019 Weidong Cao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyProgressView : NSView
-(void)setFramBackground:(NSColor *)color;
//方块跳动（方块颜色、方块个数、上下幅度、跳动速率、时间）
- (void)showWaitingWithsQuareColor:(NSColor *)color side:(NSInteger )len speed:(double )speed;
-(void)toDisappear:(BOOL )remove;

@end

NS_ASSUME_NONNULL_END
