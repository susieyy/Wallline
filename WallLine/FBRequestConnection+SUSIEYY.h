//
//  FBRequestConnection+SUSIEYY.h
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/11.
//
//

#import "FBRequestConnection.h"

@interface FBRequestConnection (SUSIEYY)
- (void)startWithBlockProgress:(SSBlockConnectionProgress)blockProgress;
- (void)startWithBlockProgressSend:(SSBlockConnectionProgress)blockProgress;
@end
