//
//  SGAsyncDecoder.m
//  SGPlayer
//
//  Created by Single on 2018/1/19.
//  Copyright © 2018年 single. All rights reserved.
//

#import "SGAsyncDecoder.h"

@interface SGAsyncDecoder ()

@property (nonatomic, assign) SGDecoderState state;

@property (nonatomic, strong) NSOperationQueue * operationQueue;
@property (nonatomic, strong) NSInvocationOperation * decodingOperation;
@property (nonatomic, strong) NSCondition * decodingCondition;

@end

@implementation SGAsyncDecoder

@synthesize index = _index;
@synthesize timebase = _timebase;
@synthesize codecpar = _codecpar;
@synthesize delegate = _delegate;

- (SGMediaType)mediaType
{
    return SGMediaTypeUnknown;
}

static SGPacket * flushPacket;

- (instancetype)init
{
    if (self = [super init])
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            flushPacket = [[SGPacket alloc] init];
        });
        _packetQueue = [[SGObjectQueue alloc] init];
    }
    return self;
}

- (BOOL)startDecoding
{
    [self startDecodingThread];
    return YES;
}

- (void)pauseDecoding
{
    if (self.state == SGDecoderStateDecoding)
    {
        self.state = SGDecoderStatePaused;
    }
}

- (void)resumeDecoding
{
    if (self.state == SGDecoderStatePaused)
    {
        self.state = SGDecoderStateDecoding;
        [self.decodingCondition lock];
        [self.decodingCondition broadcast];
        [self.decodingCondition unlock];
    }
}

- (void)stopDecoding
{
    self.state = SGDecoderStateStoped;
    [self.packetQueue destroy];
    [self.decodingCondition lock];
    [self.decodingCondition broadcast];
    [self.decodingCondition unlock];
    [self.operationQueue cancelAllOperations];
    [self.operationQueue waitUntilAllOperationsAreFinished];
}

- (BOOL)putPacket:(SGPacket *)packet
{
    [self.packetQueue putObjectSync:packet];
    [self.delegate decoderDidChangeCapacity:self];
    return YES;
}

- (void)flush
{
    [self.packetQueue flush];
    [self.packetQueue putObjectSync:flushPacket];
    [self.decodingCondition lock];
    [self.decodingCondition broadcast];
    [self.decodingCondition unlock];
    [self.delegate decoderDidChangeCapacity:self];
}

- (CMTime)duration
{
    return self.packetQueue.duration;
}

- (long long)size
{
    return self.packetQueue.size;
}

- (NSUInteger)count
{
    return self.packetQueue.count;
}

- (void)startDecodingThread
{
    if (!self.operationQueue)
    {
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 1;
        self.operationQueue.qualityOfService = NSQualityOfServiceUserInteractive;
    }
    if (!self.decodingCondition)
    {
        self.decodingCondition = [[NSCondition alloc] init];
    }
    self.decodingOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(decodingThread) object:nil];
    self.decodingOperation.queuePriority = NSOperationQueuePriorityVeryHigh;
    self.decodingOperation.qualityOfService = NSQualityOfServiceUserInteractive;
    [self.operationQueue addOperation:self.decodingOperation];
}

- (void)decodingThread
{
    self.state = SGDecoderStateDecoding;
    while (YES)
    {
        if (self.state == SGDecoderStateStoped)
        {
            break;
        }
        else if (self.state == SGDecoderStatePaused)
        {
            [self.decodingCondition lock];
            if (self.state == SGDecoderStatePaused)
            {
                [self.decodingCondition wait];
            }
            [self.decodingCondition unlock];
            continue;
        }
        else if (self.state == SGDecoderStateDecoding)
        {
            SGPacket * packet = [self.packetQueue getObjectSync];
            if (packet == flushPacket)
            {
                [self doFlush];
            }
            else if (packet)
            {
                NSArray <__kindof SGFrame *> * frames = [self doDecode:packet];
                for (__kindof SGFrame * frame in frames)
                {
                    [self.delegate decoder:self hasNewFrame:frame];
                    [frame unlock];
                }
                [packet unlock];
                [self.delegate decoderDidChangeCapacity:self];
            }
            continue;
        }
    }
}

- (void)doFlush
{
    
}

- (NSArray <__kindof SGFrame *> *)doDecode:(SGPacket *)packet
{
    return nil;
}

@end