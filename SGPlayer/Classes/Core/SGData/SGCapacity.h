//
//  SGCapacity.h
//  SGPlayer iOS
//
//  Created by Single on 2018/10/25.
//  Copyright © 2018 single. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SGTime.h"

@interface SGCapacity : NSObject <NSCopying>

@property (nonatomic) CMTime duration;
@property (nonatomic) uint64_t size;
@property (nonatomic) uint64_t count;

- (BOOL)isEqualToCapacity:(SGCapacity *)capacity;
- (BOOL)isEnough;
- (BOOL)isEmpty;

- (void)add:(SGCapacity *)capacity;
- (SGCapacity *)minimum:(SGCapacity *)capacity;

@end