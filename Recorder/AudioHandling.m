//
//  AudioHandling.m
//  Recorder
//
//  Created by Tlacael on 7/1/13.
//  Copyright (c) 2013 Tlactagon. All rights reserved.
//

#import "AudioHandling.h"
#define kFrameSize              2048
#define kYOffset                -1.f

@interface AudioHandling()



@end


@implementation AudioHandling

//singleton
static AudioHandling *sharedAudio = nil;

+ (AudioHandling *) sharedAudio
{
    
    @synchronized(self)
    {
        if (sharedAudio == nil)
        {
            sharedAudio = [[AudioHandling alloc] init];
        }
    }
    return sharedAudio;
}


- (AudioData*)audioData {
    if (!_audioData) {
        _audioData = [[AudioData alloc] init];
        _audioData.srate = 44100;
        _audioData.numChannels = 1;
        _audioData.bufferSize = 1024;
        
        _audioData.afr = [[AudioFileReader alloc] init];    // Let's do it here, not lazy instantiated
        // (otherwise we may run into performance issues)
        _audioData.afw = [[AudioFileWriter alloc] init];
        _audioData.startRecording = NO;
        _audioData.isInitialized = NO;
        _audioData.line = (GLfloat*)malloc(kFrameSize*sizeof(GLfloat)*2);
        for (int i = 0; i < kFrameSize; i++) {
            _audioData.line[2*i] = ((i - kFrameSize) / (GLfloat)kFrameSize + 0.5f) * 1.5f;
            _audioData.line[2*i + 1] = kYOffset;
        }

        NSLog(@"reinit");
    }
    return _audioData;
}

- (AudioPlayer*)audioPlayer {
    if (!_audioPlayer) {
        _audioPlayer = [[AudioPlayer alloc] initWithSampleRate:self.audioData.srate
                                                     frameSize:self.audioData.bufferSize
                                                andNumChannels:self.audioData.numChannels];
        self.audioData.isInitialized = YES;
    }
    return _audioPlayer;
}


@end
