//
//  AudioData.h
//  AudioRead
//
//  Created by Uri Nieto on 6/20/13.
//  Copyright (c) 2013 New York University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudiOS/AudioFileReader.h>
#import <AudiOS/AudioFileWriter.h>

@interface AudioData : NSObject

@property (assign, nonatomic) Float32 srate;
@property (assign, nonatomic) UInt32 numChannels;
@property (assign, nonatomic) UInt32 bufferSize;
@property (strong, nonatomic) AudioFileReader *afr;
@property (strong, nonatomic) AudioFileWriter *afw;
@property (assign, nonatomic) BOOL stopRecording;
@property (assign, nonatomic) BOOL startRecording;
@property (assign, nonatomic) BOOL isPlaying;
@property (assign, nonatomic) BOOL isInitialized;
@property (assign, nonatomic) GLfloat *line;
@property (assign, nonatomic) GLfloat file1Vol;
@property (assign, nonatomic) GLfloat file2Vol;

@end
