#import "TextDetectorManager.h"
#if __has_include(<MLKitTextRecognition/MLKitTextRecognition.h>)
@import MLKitVision;

@interface TextDetectorManager ()
@property(nonatomic, strong) MLKTextRecognizer *textRecognizer;
@property(nonatomic, assign) float scaleX;
@property(nonatomic, assign) float scaleY;
@end

@implementation TextDetectorManager

- (instancetype)init
{
  if (self = [super init]) {
    self.textRecognizer = [MLKTextRecognizer textRecognizer];
  }
  return self;
}

- (BOOL)isRealDetector
{
  return true;
}

- (void)findTextBlocksInFrame:(UIImage *)uiImage scaleX:(float)scaleX scaleY:(float) scaleY completed: (void (^)(NSArray * result)) completed
{
    self.scaleX = scaleX;
    self.scaleY = scaleY;
    MLKVisionImage *visionImage = [[MLKVisionImage alloc] initWithImage:uiImage];
    NSData *imageDataJPG = UIImageJPEGRepresentation(uiImage, 1.0);
    NSMutableArray *textBlocks = [[NSMutableArray alloc] init];
    [_textRecognizer processImage:visionImage
                       completion:^(MLKText *_Nullable result,
                                    NSError *_Nullable error) {
                           if (error != nil || result == nil) {
                               completed(textBlocks);
                           } else {
                               completed([self processBlocks:result.blocks :imageDataJPG]);
                           }
                       }];
}

- (NSArray *)processBlocks:(NSArray *)features :(NSData *)imageDataJPG
{
  NSMutableArray *textBlocks = [[NSMutableArray alloc] init];
  for (MLKTextBlock *textBlock in features) {
      NSDictionary *textBlockDict = 
      @{@"type": @"block", @"value" : textBlock.text, @"bounds" : [self processBounds:textBlock.frame], @"components" : [self processLine:textBlock.lines]};
      [textBlocks addObject:textBlockDict];
  }
    [textBlocks addObject:@{@"imageData":[imageDataJPG base64EncodedStringWithOptions:0]}];
  return textBlocks;
}

- (NSArray *)processLine:(NSArray *)lines
{
  NSMutableArray *lineBlocks = [[NSMutableArray alloc] init];
  for (MLKTextLine *textLine in lines) {
        NSDictionary *textLineDict = 
        @{@"type": @"line", @"value" : textLine.text, @"bounds" : [self processBounds:textLine.frame], @"components" : [self processElement:textLine.elements]};
        [lineBlocks addObject:textLineDict];
  }
  return lineBlocks;
}

- (NSArray *)processElement:(NSArray *)elements
{
  NSMutableArray *elementBlocks = [[NSMutableArray alloc] init];
  for (MLKTextElement *textElement in elements) {
        NSDictionary *textElementDict = 
        @{@"type": @"element", @"value" : textElement.text, @"bounds" : [self processBounds:textElement.frame]};
        [elementBlocks addObject:textElementDict];
  }
  return elementBlocks;
}

- (NSDictionary *)processBounds:(CGRect)bounds
{
  float width = bounds.size.width;
  float height = bounds.size.height;
  float originX = bounds.origin.x;
  float originY = bounds.origin.y;
  NSDictionary *boundsDict =
  @{
    @"size" : 
              @{
                @"width" : @(width), 
                @"height" : @(height)
                }, 
    @"origin" : 
              @{
                @"x" : @(originX),
                @"y" : @(originY)
                }
    };
  return boundsDict;
}

@end
#else

@interface TextDetectorManager ()
@end

@implementation TextDetectorManager

- (instancetype)init
{
  self = [super init];
  return self;
}

- (BOOL)isRealDetector
{
  return false;
}

- (void)findTextBlocksInFrame:(UIImage *)image scaleX:(float)scaleX scaleY:(float) scaleY completed:(postRecognitionBlock)completed;
{
  NSLog(@"TextDetector not installed, stub used!");
  NSArray *features = @[@"Error, Text Detector not installed"];
  completed(features);
}

@end
#endif
