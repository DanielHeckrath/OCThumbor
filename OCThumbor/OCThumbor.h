//
//  OCThumbor.h
//  
//
//  Created by Daniel Heckrath on 08.03.14.
//
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
#define THUMBOR_EXTERN		extern "C" __attribute__((visibility ("default")))
#else
#define THUMBOR_EXTERN	        extern __attribute__((visibility ("default")))
#endif

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

/**
 Horizontal alignment for crop positioning.
 */
typedef NS_ENUM(NSUInteger, ThumborHorizontalAlign) {
    ThumborHorizontalAlignLeft,
    ThumborHorizontalAlignMiddle,
    ThumborHorizontalAlignRight
};

/**
 Vertical alignment for crop positioning.
 */
typedef NS_ENUM(NSUInteger, ThumborVerticalAlign) {
    ThumborVerticalAlignTop,
    ThumborVerticalAlignMiddle,
    ThumborVerticalAlignBottom
};

/**
 Orientation from where to get the pixel color for trim.
 */
typedef NS_ENUM(NSUInteger, ThumborTrimPixelColor) {
    /**
     top-left
     */
    ThumborTrimPixelColorTopLeft,
    /**
     bottom-right
     */
    ThumborTrimPixelColorBottomRight
};

/**
 Image formats supported by Thumbor.
 */
typedef NS_ENUM(NSUInteger, ThumborImageFormat) {
    ThumborImageFormatGif,
    ThumborImageFormatJpeg,
    ThumborImageFormatPng,
    ThumborImageFormatWebp
};

/**
 Original size for image width or height.
 */
THUMBOR_EXTERN const NSInteger THUMBOR_ORIGINAL_SIZE;

@interface OCThumborURLBuilder : NSObject

/**
 Resize picture to desired size.
 
 @param width  Desired width.
 @param height Desired height.
 
 @throws NSInvalidArgumentException if width or height is less than 0 or both are 0.
 */
- (instancetype)resizeWidth:(int)width height:(int)height;

/**
 Flip the image vertically.
 
 @throws NSInternalInconsistencyException if image has not been marked for resize.
 */
- (instancetype)flipVertically;

/**
 Flip the image horizontally.
 
 @throws NSInternalInconsistencyException if image has not been marked for resize.
 */
- (instancetype)flipHorizontally;

/**
 Contrain the image size inside the resized box, scaling as needed.
 
 @throws NSInternalInconsistencyException if image has not been marked for resize.
 */
- (instancetype)fitIn;

/**
 Crop the image between two points.
 
 @param top    Top bound.
 @param left   Left bound.
 @param bottom Bottom bound.
 @param right  Right bound.
 
 @throws NSInvalidArgumentException if top or left are less than zero or bottom or right are less than one or less than top or left, respectively.
 */
- (instancetype)cropTop:(int)top left:(int)left right:(int)bottom bottom:(int)right;

/**
 Set the horizontal alignment for the image when cropping.
 
 @param horizontalAlign Horizontal alignment.
 
 @throws NSInternalInconsistencyException if image has not been marked for crop.
 */
- (instancetype)horizontalAlign:(ThumborHorizontalAlign)horizontalAlign;

/**
 Set the vertical alignment for the image when cropping.
 
 @param verticalAlign Vertical alignment.
 
 @throws NSInternalInconsistencyException if image has not been marked for crop.
 */
- (instancetype)verticalAlign:(ThumborVerticalAlign)verticalAlign;

/**
 Set the horizontal and vertical alignment for the image when cropping.
 
 @param verticalAlign   Vertical alignment.
 @param horizontalAlign Horizontal alignment.
 
 @throws NSInternalInconsistencyException if image has not been marked for crop.
 */
- (instancetype)alignVertically:(ThumborVerticalAlign)verticalAlign horizontally:(ThumborHorizontalAlign)horizontalAlign;

/**
 Use smart cropping for determining the important portion of an image.
 
 @throws NSInternalInconsistencyException if image has not been marked for crop.
 */
- (instancetype)smart;

/**
 Removing surrounding space in image.
 */
- (instancetype)trim;

/**
 Removing surrounding space in image. Get trim color from specified pixel.
 
 @param trimColor orientation from where to get the pixel color.
 */
- (instancetype)trim:(ThumborTrimPixelColor)trimColor;

/**
 Removing surrounding space in image. Get trim color from specified pixel.
 
 @param trimColor orientation from where to get the pixel color.
 @param tolerance 0 - 442. This is the euclidian distance between the colors of the reference pixel and the surrounding pixels is used. If the distance is within the tolerance they'll get trimmed.
 */
- (instancetype)trim:(ThumborTrimPixelColor)trimColor withTolerance:(int)tolerance;

/**
 Use legacy encryption when constructing a safe URL.
 */
- (instancetype)legacy;

/**
 Add one or more filters to the image.
 
 @throws NSInvalidArgumentException if no arguments supplied or an argument is empty
 */
- (instancetype)filter:(NSString *)filterValue, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Add one or more filters to the image.
 
 @throws NSInvalidArgumentException if filters is empty or an argument is blank
 */
- (instancetype)filterFromArray:(NSArray *)filters;

/**
 Build the URL. This will either call toUrlSafe or toUrlUnsafe depending on whether a key was set.
 */
- (NSString *)toUrl;

/**
 Build an unsafe version of the URL.
 */
- (NSString *)toUrlUnsafe;

/**
 Build a safe version of the URL. Requires a non-nil key.
 */
- (NSString *)toUrlSafe;

/**
 Build the metadata URL. This will either call toMetaSafe or toMetaUnsafe depending on whether a key was set.
 */
- (NSString *)toMeta;

/**
 Build an unsafe version of the metadata URL.
 */
- (NSString *)toMetaUnsafe;

/**
 Build a safe version of the metadata URL. Requires a non-nil key.
 */
- (NSString *)toMetaSafe;

#pragma mark - Filter Methods

/**
 This filter increases or decreases the image brightness.
 
 @param amount -100 to 100 - The amount (in %) to change the image brightness. Positive numbers make the image brighter and negative numbers make the image darker.
 
 @throws NSInvalidArgumentException if amount is outside bounds.
 */
+ (NSString *)brightness:(int)amount;

/**
 The filter increases or decreases the image contrast.
 
 @param amount -100 to 100 - The amount (in %) to change the image contrast. Positive numbers increase contrast and negative numbers decrease contrast.
 
 @throws NSInvalidArgumentException if amount is outside bounds.
 */
+ (NSString *)contrast:(int)amount;

/**
 This filter adds noise to the image.
 
 @param amount 0 to 100 - The amount (in %) of noise to add to the image.
 
 @throws NSInvalidArgumentException if amount is outside bounds.
 */
+ (NSString *)noise:(int)amount;

/**
 This filter changes the overall quality of the JPEG image (does nothing for PNGs or GIFs).
 
 @param amount 0 to 100 - The quality level (in %) that the end image will feature.
 
 @throws NSInvalidArgumentException if amount is outside bounds.
 */
+ (NSString *)quality:(int)amount;

/**
 This filter changes the amount of color in each of the three channels.
 
 @param red   The amount of redness in the picture. Can range from -100 to 100 in percentage.
 @param green The amount of greenness in the picture. Can range from -100 to 100 in percentage.
 @param blue  The amount of blueness in the picture. Can range from -100 to 100 in percentage.
 
 @throws NSInvalidArgumentException if red, green, or blue are outside of bounds.
 */
+ (NSString *)red:(int)red green:(int)green blue:(int)blue;

/**
 This filter adds rounded corners to the image using the white as the background.
 
 @param radius amount of pixels to use as radius.
 */
+ (NSString *)roundCorner:(int)radius;

/**
 This filter adds rounded corners to the image using the specified color as the background.
 
 @param radius amount of pixels to use as radius.
 @param color  fill color for clipped region.
 */
+ (NSString *)roundCorner:(int)radius color:(int)color;

/**
 This filter adds rounded corners to the image using the specified color as the background.
 
 @param radiusInner amount of pixels to use as radius.
 @param radiusOuter specifies the second value for the ellipse used for the radius. Use 0 for no value.
 @param color       fill color for clipped region.
 */
+ (NSString *)roundCorner:(int)radiusInner radiusOuter:(int)radiusOuter color:(int)color;

/**
 This filter adds a watermark to the image.
 
 @param imageUrl
 
 @throws NSInvalidArgumentException if imageUrl is blank
 */
+ (NSString *)watermark:(NSString *)imageUrl;

/**
 This filter adds a watermark to the image.
 
 @param imageUrl
 @param x            Horizontal position that the watermark will be in. Positive numbers indicate position from the left and negative numbers indicate position from the right.
 @param y            Vertical position that the watermark will be in. Positive numbers indicate position from the top and negative numbers indicate position from the bottom.
 
 @throws NSInvalidArgumentException if imageUrl is blank
 */
+ (NSString *)watermark:(NSString *)imageUrl x:(int)x y:(int)y;

/**
 This filter adds a watermark to the image.
 
 @param imageUrl
 @param x            Horizontal position that the watermark will be in. Positive numbers indicate position from the left and negative numbers indicate position from the right.
 @param y            Vertical position that the watermark will be in. Positive numbers indicate position from the top and negative numbers indicate position from the bottom.
 @param transparency Watermark image transparency. Should be a number between 0 (fully opaque) and 100 (fully transparent).
 
 @throws NSInvalidArgumentException if imageUrl is blank or transparency is outside of bounds
 */
+ (NSString *)watermark:(NSString *)imageUrl x:(int)x y:(int)y transparency:(int)transparency;

/**
 This filter adds a watermark to the image.
 
 @param builder
 
 @throws NSInvalidArgumentException if builder is nil
 */
+ (NSString *)watermarkWithBuilder:(OCThumborURLBuilder *)builder;

/**
 This filter adds a watermark to the image.
 
 @param builder
 @param x            Horizontal position that the watermark will be in. Positive numbers indicate position from the left and negative numbers indicate position from the right.
 @param y            Vertical position that the watermark will be in. Positive numbers indicate position from the top and negative numbers indicate position from the bottom.
 
 @throws NSInvalidArgumentException if builder is nil
 */
+ (NSString *)watermarkWithBuilder:(OCThumborURLBuilder *)builder x:(int)x y:(int)y;

/**
 This filter adds a watermark to the image.
 
 @param builder      
 @param x            Horizontal position that the watermark will be in. Positive numbers indicate position from the left and negative numbers indicate position from the right.
 @param y            Vertical position that the watermark will be in. Positive numbers indicate position from the top and negative numbers indicate position from the bottom.
 @param transparency Watermark image transparency. Should be a number between 0 (fully opaque) and 100 (fully transparent).
 
 @throws NSInvalidArgumentException if builder is nil
 */
+ (NSString *)watermarkWithBuilder:(OCThumborURLBuilder *)builder x:(int)x y:(int)y transparency:(int)transparency;

/**
 This filter enhances apparent sharpness of the image. It's heavily based on Marco Rossini's excellent Wavelet sharpen GIMP plugin. Check http://registry.gimp.org/node/9836 for details about how it work.
 
 @param amount        Sharpen amount. Typical values are between 0.0 and 10.0.
 @param radius        Sharpen radius. Typical values are between 0.0 and 2.0.
 @param luminanceOnly Sharpen only luminance channel.
 */
+ (NSString *)sharpen:(double)amount radius:(double)radius luminanceOnly:(BOOL)luminanceOnly;

/**
 This filter permit to return an image sized exactly as requested wherever is its ratio by filling with chosen color the missing parts. Usually used with "fit-in" or "adaptive-fit-in"
 */
+ (NSString *)fill:(int)color;

/**
 Specify the output format of the image.
 
 @see ThumborImageFormat
 */
+ (NSString *)format:(ThumborImageFormat)format;

/**
 This filter uses a 9-patch to overlay the image.
 
 @param imageUrl Watermark image URL. It is very important to understand that the same image loader that Thumbor uses will be used here.
 */
+ (NSString *)frame:(NSString *)imageUrl;

/**
 This filter strips the ICC profile from the image.
 */
+ (NSString *)stripicc;

/**
 This filter changes the image to grayscale.
 */
+ (NSString *)grayscale;

/**
 This filter equalizes the color distribution in the image.
 */
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