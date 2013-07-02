//
//  RecSecondViewController.m
//  Recorder
//
//  Created by Tlacael on 6/29/13.
//  Copyright (c) 2013 Tlactagon. All rights reserved.
//

#import "RecSecondViewController.h"
#import "AudioHandling.h"

@interface RecSecondViewController ()
@property (weak, nonatomic) AudioHandling *aud;

@end

@implementation RecSecondViewController


NSArray *tableData;

// Our Audio Callback function
void myAudioCallback2(Float32 * buffer, UInt32 numFrames, void * userData) {
    
    // Get our structure
    AudioData *audioData = (__bridge AudioData *)(userData);
    
    // Read samples from audio file
    Float32 *audioFileBuf = [audioData.afr readSamplesWithBufferSize:numFrames];
    
    // Set the input buffer to zeroes
    memset(buffer, 0, sizeof(Float32) * numFrames * audioData.numChannels);
    
    // Initialise the audio file index for reading
    int af_idx = 0;
       
    //NSLog(@"%d", audioData.afr.numChannels);

    // Main audio loop
    for (int i = 0; i < numFrames; i++) {
        
        // For each channel, let's add one sample from the audio file and another from the sinusoid
        buffer[audioData.numChannels*i] = 0.5 * audioFileBuf[af_idx++];      // left channel
        if (audioData.afr.numChannels == 2) {
            buffer[audioData.numChannels*i +1] = 0.5 * audioFileBuf[af_idx++];  // right channel
            
        }
    }


}


#pragma mark - functions for file url getting
- (NSString*)getBasepath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

- (NSArray*)printFileNames {
    
    
    NSURL *url = [NSURL URLWithString:[self getBasepath]];
    NSError *error = nil;
    NSArray *properties = [NSArray arrayWithObjects: NSURLLocalizedNameKey,
                           NSURLCreationDateKey, NSURLLocalizedTypeDescriptionKey, nil];
    
    // [(NSArray*)allPeople mutableCopy];
    NSMutableArray *array = [[[NSFileManager defaultManager]
                              contentsOfDirectoryAtURL:url
                              includingPropertiesForKeys:properties
                              options:(NSDirectoryEnumerationSkipsHiddenFiles)
                              error:&error] mutableCopy];
    
    if (array == nil) {
        // Handle the error
    }
    
       // NSLog(@"directory contents: %@", array);
    NSMutableArray *filenames = [[NSMutableArray alloc]init];
    
    for (id obj in array){
        NSString *fname = [NSString stringWithFormat:@"%@",obj];
        NSArray *curFileComponents = [fname componentsSeparatedByString:@"/"];
        
        [filenames addObject:[curFileComponents lastObject]];
    }

    return filenames;
    
}

#pragma mark - Lazy Instantiation


- (AudioHandling  *)aud {
    if (!_aud) {
        _aud = [AudioHandling sharedAudio];
    }
    return _aud;
}

#pragma mark - View loading

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    tableData = [self printFileNames];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
     tableData = [self printFileNames];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section

{
    return @"Recordings";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    //tableData = [self printFileNames];
    
    cell.textLabel.text = [tableData objectAtIndex:indexPath.row];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.aud.audioData.isPlaying) {
        [self.aud.audioPlayer stopAudio];

    }
    NSString *basepath = [[self getBasepath] stringByAppendingString:@"/"];
    NSString *filename = [tableData objectAtIndex:[indexPath row]];
    filename = [basepath stringByAppendingString:filename];
    NSLog(@"Here it is%s", filename.UTF8String);
    

    [self.aud.audioData.afr loadFileWithName:filename andSampleRate:self.aud.audioData.srate hasFullPath:YES];
    

    NSLog(@"Track loaded");
    self.aud.audioData.isPlaying = YES;
    [self.aud.audioPlayer startWithCallback:myAudioCallback2 andUserData: (__bridge void *)(self.aud.audioData)];
        NSLog(@"audio started");

//    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    NSLog(@"%@", [tableData objectAtIndex:[indexPath row]] );

}


@end
