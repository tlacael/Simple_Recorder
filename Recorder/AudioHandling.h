//
//  AudioHandling.h
//  Recorder
//
//  Created by Tlacael on 7/1/13.
//  Copyright (c) 2013 Tlactagon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioData.h"
#import <AudiOS/AudioPlayer.h>

@interface AudioHandling : NSObject

@property (strong, nonatomic) AudioData *audioData;
@property (strong, nonatomic) AudioPlayer *audioPlayer;

+ (AudioHandling *) sharedAudio;
@end
