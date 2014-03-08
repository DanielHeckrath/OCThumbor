//
//  OCThumbor.h
//  
//
//  Created by Daniel Heckrath on 08.03.14.
//
//

#import <Foundation/Foundation.h>

@class OCThumborURLBuilder;

@interface OCThumbor : NSObject

@property (nonatomic, strong, readonly) NSString *host;
@property (nonatomic, strong, readonly) NSString *key;

/**
 Create a new instance for the specified host.
 
 @param host the url your thumbor instance is available under.
 
 @return instance associated with the specified host
 */
+ (instancetype)createWithHost:(NSString *)host;

/**
 Create a new instance for the specified host and encryption key.
 
 @param host the url your thumbor instance is available under.
 @param key  the secret key to use for creating safe urls.
 
 @return instance associated with the specified host and key
 */
+ (instancetype)createWithHost:(NSString *)host key:(NSString *)key;

/**
 Begin building a url for this host with the specified image.
 
 @param image url or image name
 
 @return URLBuilder for the specified image
 */
- (OCThumborURLBuilder *)buildImage:(NSString *)image;

@end

typedef NS_ENUM(NSUInteger, ThumborHorizontalAlign) {
    ThumborHorizontalAlignLeft,
    ThumborHorizontalAlignMiddle,
    ThumborHorizontalAlignRight
};

typedef NS_ENUM(NSUInteger, ThumborVerticalAlign) {
    ThumborVerticalAlignTop,
    ThumborVerticalAlignMiddle,
    ThumborVerticalAlignBottom
};

typedef NS_ENUM(NSUInteger, ThumborTrimPixelColor) {
    ThumborTrimPixelColorTopLeft,
    ThumborTrimPixelColorBottomRight
};

typedef NS_ENUM(NSUInteger, ThumborImageFormat) {
    ThumborImageFormatGif,
    ThumborImageFormatJpeg,
    ThumborImageFormatPng,
    ThumborImageFormatWebp
};

@interface OCThumborURLBuilder : NSObject

- (instancetype)resizeWidth:(int)width height:(int)height;

/**
 Flip the image vertically.
 */
- (instancetype)flipVertically;

/**
 Flip the image horizontally.
 */
- (instancetype)flipHorizontally;

/**
 Contrain the image size inside the resized box, scaling as needed.
 */
- (instancetype)fitIn;

/**
 Crop the image between two points.
 
 @param top    Top bound.
 @param left   Left bound.
 @param bottom Bottom bound.
 @param right  Right bound.
 */
- (instancetype)cropTop:(int)top left:(int)left right:(int)bottom bottom:(int)right;

- (instancetype)horizontalAlign:(ThumborHorizontalAlign)horizontalAlign;

- (instancetype)verticalAlign:(ThumborVerticalAlign)verticalAlign;

- (instancetype)alignVertically:(ThumborVerticalAlign)verticalAlign horizontally:(ThumborHorizontalAlign)horizontalAlign;

- (instancetype)smart;

- (instancetype)trim;

- (instancetype)trim:(ThumborTrimPixelColor)trimColor;

- (instancetype)trim:(ThumborTrimPixelColor)trimColor withTolerance:(NSUInteger)tolerance;

- (instancetype)legacy;

- (instancetype)filter:(NSString *)filterValue, ... NS_REQUIRES_NIL_TERMINATION;

- (instancetype)filterFromArray:(NSArray *)filters;

- (NSString *)toUrl;
- (NSString *)toUrlUnsafe;
- (NSString *)toUrlSafe;

- (NSString *)toMeta;
- (NSString *)toMetaUnsafe;
- (NSString *)toMetaSafe;

#pragma mark - Filter Methods

+ (NSString *)brightness:(NSInteger)amount;
+ (NSString *)contrast:(NSInteger)amount;
+ (NSString *)noise:(NSInteger)amount;
+ (NSString *)quality:(NSInteger)amount;
+ (NSString *)red:(int)red green:(int)green blue:(int)blue;
+ (NSString *)roundCorner:(int)radius;
+ (NSString *)roundCorner:(int)radius color:(int)color;
+ (NSString *)roundCorner:(int)radiusInner radiusOuter:(int)radiusOuter color:(int)color;
+ (NSString *)watermark:(NSString *)imageUrl;
+ (NSString *)watermark:(NSString *)imageUrl x:(int)x y:(int)y;
+ (NSString *)watermark:(NSString *)imageUrl x:(int)x y:(int)y transparency:(int)transparency;
+ (NSString *)watermarkWithBuilder:(OCThumborURLBuilder *)builder;
+ (NSString *)watermarkWithBuilder:(OCThumborURLBuilder *)builder x:(int)x y:(int)y;
+ (NSString *)watermarkWithBuilder:(OCThumborURLBuilder *)builder x:(int)x y:(int)y transparency:(int)transparency;
+ (NSString *)sharpen:(double)amount radius:(double)radius luminanceOnly:(BOOL)luminanceOnly;
+ (NSString *)fill:(int)color;
+ (NSString *)format:(ThumborImageFormat)format;
+ (NSString *)frame:(NSString *)imageUrl;
+ (NSString *)stripicc;
+ (NSString *)grayscale;
+ (NSString *)equalize;

@end

#pragma mark - Shorthands for filter methods

#define th_brightness(amount)                      [OCThumborURLBuilder brightness:amount]
#define th_contrast(amount)                        [OCThumborURLBuilder contrast:amount]
#define th_noise(amount)                           [OCThumborURLBuilder noise:amount]
#define th_quality(amount)                         [OCThumborURLBuilder quality:amount]
#define th_rgb(r,g,b)                              [OCThumborURLBuilder red:r green:g blue:b]
#define th_roundCorner(radius)                     [OCThumborURLBuilder roundCorner:radius]
#define th_roundCornerC(radius,color)              [OCThumborURLBuilder roundCorner:radius color:color]
#define th_roundCornerOC(radius,outer,color)       [OCThumborURLBuilder roundCorner:radius radiusOuter:outer color:color]
#define th_watermark(i)                            [OCThumborURLBuilder watermark:i]
#define th_watermarkXY(i,px,py)                    [OCThumborURLBuilder watermark:i x:px y:py]
#define th_watermarkXYA(i,px,py,a)                 [OCThumborURLBuilder watermark:i x:px y:py transparency:a]
#define th_watermarkB(b)                           [OCThumborURLBuilder watermarkWithBuilder:b]
#define th_watermarkBXY(b,px,py)                   [OCThumborURLBuilder watermarkWithBuilder:b x:px y:py]
#define th_watermarkBXYA(b,px,py,a)                [OCThumborURLBuilder watermarkWithBuilder:b x:px y:py transparency:a]
#define th_sharpen(a,r,l)                          [OCThumborURLBuilder sharpen:a radius:r luminanceOnly:l]
#define th_fill(c)                                 [OCThumborURLBuilder fill:c]
#define th_format(i)                               [OCThumborURLBuilder format:i]
#define th_frame(i)                                [OCThumborURLBuilder frame:i]
#define th_stripicc                                [OCThumborURLBuilder stripicc]
#define th_grayscale                               [OCThumborURLBuilder grayscale]
#define th_equalize                                [OCThumborURLBuilder equalize]