//
//  AReadViewController.m
//  AudioRead
//
//  Created by Uri Nieto on 6/20/13.
//  Copyright (c) 2013 New York University. All rights reserved.
//

#import "visualizeViewController.h"
#import "AudioHandling.h"


#define kAccelerometerUpdates   600. // Hz
#define kFrameSize              2048


@interface visualizeViewController ()

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;
@property (assign, nonatomic) float rotation;
@property (weak, nonatomic) AudioHandling *aud;

@end

@implementation visualizeViewController

#pragma mark - Audio Callback


#pragma mark - Lazy Instantiation


- (void)setupGraphics
{
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    self.delegate = self;
    
    [EAGLContext setCurrentContext:self.context];
    
    
    self.effect = [[GLKBaseEffect alloc] init];
    
    // Let's color the line
    self.effect.useConstantColor = GL_TRUE;
    
    // Make the line a cyan color
    self.effect.constantColor = GLKVector4Make(
                                               0.0f, // Red
                                               0.0f, // Green
                                               0.0f, // Blue
                                               0.0f);// Alpha
}

#pragma mark lazy instantiation
- (AudioHandling  *)aud {
    if (!_aud) {
        _aud = [AudioHandling sharedAudio];
    }
    return _aud;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    
    // Setup Open GL
    [self setupGraphics];
    
   
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GLKViewControllerDelegate

- (void)glkViewControllerUpdate:(GLKViewController *)controller {
//- (void)update{
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -3.0f);
    baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, _rotation, 0.0f, 1.0f, 0.0f);
    
    // Compute the model view matrix for the object rendered with GLKit
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 0.f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
    
    self.effect.transform.modelviewMatrix = modelViewMatrix;
    
    _rotation += self.timeSinceLastUpdate * 0.5f;
    
    // Set Background color
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Prepare the effect for rendering
    [self.effect prepareToDraw];
    
    // Create an handle for a buffer object array
    GLuint bufferObjectNameArray;
    
    // Have OpenGL generate a buffer name and store it in the buffer object array
    glGenBuffers(1, &bufferObjectNameArray);
    
    // Bind the buffer object array to the GL_ARRAY_BUFFER target buffer
    glBindBuffer(GL_ARRAY_BUFFER, bufferObjectNameArray);
    
    // Send the line data over to the target buffer in GPU RAM
    glBufferData(
                 GL_ARRAY_BUFFER,   // the target buffer
                 kFrameSize*sizeof(GLfloat)*2,      // the number of bytes to put into the buffer
                 self.aud.audioData.line,              // a pointer to the data being copied
                 GL_STATIC_DRAW);   // the usage pattern of the data
    
    // Enable vertex data to be fed down the graphics pipeline to be drawn
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    
    // Specify how the GPU looks up the data
    glVertexAttribPointer(
                          GLKVertexAttribPosition, // the currently bound buffer holds the data
                          2,                       // number of coordinates per vertex
                          GL_FLOAT,                // the data type of each component
                          GL_FALSE,                // can the data be scaled
                          2*4,                     // how many bytes per vertex (2 floats per vertex)
                          NULL);                   // offset to the first coordinate, in this case 0
    
    glDrawArrays(GL_LINE_STRIP, 0, kFrameSize); // render
}


@end
