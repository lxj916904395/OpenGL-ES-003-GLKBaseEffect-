//
//  ViewController.m
//  OpenGL-ES-003-GLKBaseEffect加载图片纹理
//
//  Created by zhongding on 2019/1/2.
//

#import "ViewController.h"

@interface ViewController ()
@property(strong ,nonatomic) EAGLContext *context;//上下文
@property(strong ,nonatomic) GLKBaseEffect *effect;//效果
@property(assign ,nonatomic) int count;//顶点数

@property(assign ,nonatomic) CGFloat xRot;//X轴旋转度数
@property(assign ,nonatomic) CGFloat yRot;//Y轴旋转度数
@property(assign ,nonatomic) CGFloat zRot;//Z轴旋转度数

@property(assign ,nonatomic) BOOL xEnable;//是否开启X轴旋转
@property(assign ,nonatomic) BOOL yEnable;//是否开启Y轴旋转
@property(assign ,nonatomic) BOOL zEnable;//是否开启Z轴旋转

@property(strong ,nonatomic) NSTimer *timer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupContext];
    [self render];
    [self setupTimer];
}


- (void)render{
    
    GLfloat step = 0.5f;
    //顶点坐标，     颜色，     纹理坐标
    GLfloat vertexs[] = {
        -step,step,0,   1.0,0.3,0.5,    0.0,1.0,
        step,step,0,    0.2,1.0,0.3,    1.0,1.0,
        -step,-step,0,  0.4,0.1,0.7,    0.0,0.0,
        step,-step,0,   0.2,0.5,1.0,    1.0,0.0,
        
        //顶点
        0,0,1.0,        0.20,0.9,0.4,    0.5,0.5
    };
    
    //索引数组
    GLuint indexs[] = {
        0,1,3,
        0,3,2,
        0,2,4,
        0,4,1,
        2,4,3,
        1,3,4
    };
    
    //顶点数
    self.count = sizeof(indexs)/sizeof(GLuint);
    
    //顶点数据缓冲区
    GLuint vertexsBuffer;
    glGenBuffers(1, &vertexsBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexsBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexs), vertexs, GL_DYNAMIC_DRAW);
    
    //索引数组缓冲区
    GLuint indexsBuffer;
    glGenBuffers(1, &indexsBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexsBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indexs), indexs, GL_DYNAMIC_DRAW);
    
    //开启顶点数据读取
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, 0);
    
    //开启顶点颜色读取
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)* 8, (GLfloat*)NULL+3);
    
    //开启纹理坐标读取
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*8, (GLfloat*)NULL+6);
    
    //纹理文件
    NSString *file = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"jpg"];
    
    //纹理文件读取方式
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"1",GLKTextureLoaderOriginBottomLeft ,nil];
    //纹理信息
    GLKTextureInfo *info = [GLKTextureLoader textureWithContentsOfFile:file options:dict error:nil];
    
    //初始化效果
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.texture2d0.enabled = GL_TRUE;
    self.effect.texture2d0.name = info.name;
    
    
    CGSize size = self.view.frame.size;
    //设置投影矩阵
    CGFloat accept = size.width/size.height;
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90.0f), accept, 1.0f, 15.0);
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    //设置模型视图矩阵
    //往z轴负方向移动
    GLKMatrix4 modeViewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 0.0f, -2.0f);
    self.effect.transform.modelviewMatrix = modeViewMatrix;
}

//开启定时器
- (void)setupTimer{
    self.timer = [NSTimer timerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        self.xRot += 0.1 *self.xEnable;
        self.yRot +=0.1*self.yEnable;
        self.zRot += 0.1*self.zEnable;
    }];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}


- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(1.0, 0.3, 0.3, 1.0);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    [self.effect prepareToDraw];
    glDrawElements(GL_TRIANGLES, self.count, GL_UNSIGNED_INT, 0);
}

- (void)update{
    GLKMatrix4 modelviewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 0.0f, -2.0f);
    //绕X轴旋转
    modelviewMatrix = GLKMatrix4RotateX(modelviewMatrix, self.xRot);
    //绕Y轴旋转
    modelviewMatrix = GLKMatrix4RotateY(modelviewMatrix, self.yRot);
    //绕Z轴旋转
    modelviewMatrix = GLKMatrix4RotateZ(modelviewMatrix, self.zRot);
    
    self.effect.transform.modelviewMatrix = modelviewMatrix;
}


//设置上下文
- (void)setupContext{
    
    GLKView* view = (GLKView*)self.view;
    self.context = [[EAGLContext alloc] initWithAPI:(kEAGLRenderingAPIOpenGLES3)];
    
    view.context = self.context;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [EAGLContext setCurrentContext:self.context];
    
    glEnable(GL_DEPTH_TEST);
}


- (IBAction)clickY:(id)sender {
    self.yEnable = !self.yEnable;

}

- (IBAction)clickX:(id)sender {
    self.xEnable = !self.xEnable;
}


- (IBAction)clickZ:(id)sender {
    self.zEnable = !self.zEnable;
}

@end
