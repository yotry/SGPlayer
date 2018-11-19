//
//  SGMutableAsset.h
//  SGPlayer
//
//  Created by Single on 2018/11/14.
//  Copyright © 2018 single. All rights reserved.
//

#import "SGAsset.h"
#import "SGSegment.h"
#import "SGDefines.h"

@interface SGMutableAsset : SGAsset

- (int32_t)addTrack:(SGMediaType)type;

- (BOOL)insertSegment:(SGSegment *)segment trackID:(int32_t)trackID;

@end