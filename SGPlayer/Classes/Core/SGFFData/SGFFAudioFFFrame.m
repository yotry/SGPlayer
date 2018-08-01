//
//  SGFFAudioFFFrame.m
//  SGPlayer
//
//  Created by Single on 2018/6/26.
//  Copyright © 2018 single. All rights reserved.
//

#import "SGFFAudioFFFrame.h"

@implementation SGFFAudioFFFrame

- (instancetype)init
{
    if (self = [super init])
    {
        NSLog(@"%s", __func__);
        _coreFrame = av_frame_alloc();
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
    if (_coreFrame)
    {
        av_frame_free(&_coreFrame);
        _coreFrame = NULL;
    }
}

- (void)fillWithTimebase:(CMTime)timebase packet:(SGFFPacket *)packet
{
    self.position = SGTimeMultiply(timebase, av_frame_get_best_effort_timestamp(self.coreFrame));
    self.duration = SGTimeMultiply(timebase, av_frame_get_pkt_duration(self.coreFrame));
    self.size = av_frame_get_pkt_size(self.coreFrame);
    
    self.format = self.coreFrame->format;
    self.numberOfSamples = self.coreFrame->nb_samples;
    self.sampleRate = av_frame_get_sample_rate(self.coreFrame);
    self.numberOfChannels = av_frame_get_channels(self.coreFrame);
    self.channelLayout = av_frame_get_channel_layout(self.coreFrame);
    self.bestEffortTimestamp = av_frame_get_best_effort_timestamp(self.coreFrame);
    self.packetPosition = av_frame_get_pkt_pos(self.coreFrame);
    self.packetDuration = av_frame_get_pkt_duration(self.coreFrame);
    self.packetSize = av_frame_get_pkt_size(self.coreFrame);
    self.data = self.coreFrame->data;
    self.linesize = self.coreFrame->linesize;
}

- (void)clear
{
    [super clear];
    if (_coreFrame)
    {
        av_frame_unref(_coreFrame);
    }
}

@end