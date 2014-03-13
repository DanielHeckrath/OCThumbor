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

#if !defined(THUMBOR_INLINE)
# if defined(__STDC_VERSION__) && __STDC_VERSION__ >= 199901L
#  define THUMBOR_INLINE static inline
# elif defined(__MWERKS__) || defined(__cplusplus)
#  define THUMBOR_INLINE static inline
# elif defined(__GNUC__)
#  define THUMBOR_INLINE static __inline__
# else
#  define THUMBOR_INLINE static
# endif
#endif /* !defined(THUMBOR_INLINE) */

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
typedef NS_ENUM(NSUInteger, HorizontalAlign) {
    HorizontalAlignNone,
    HorizontalAlignLeft,
    HorizontalAlignCenter,
    HorizontalAlignRight
};

/**
 Vertical alignment for crop positioning.
 */
typedef NS_ENUM(NSUInteger, VerticalAlign) {
    VerticalAlignNone,
    VerticalAlignTop,
    VerticalAlignMiddle,
    VerticalAlignBottom
};

/**
 Orientation from where to get the pixel color for trim.
 */
typedef NS_ENUM(NSUInteger, TrimPixelColor) {
    /**
     Does not translate into string
     */
    TrimPixelColorNone,
    /**
     top-left
     */
    TrimPixelColorTopLeft,
    /**
     bottom-right
     */
    TrimPixelColorBottomRight
};

/**
 Image formats supported by Thumbor.
 */
typedef NS_ENUM(NSUInteger, ImageFormat) {
    ImageFormatGif,
    ImageFormatJpeg,
    ImageFormatPng,
    ImageFormatWebp
};

typedef struct CropRect {
    int top, left, bottom, right;  // specify top-left and bottom-right crop point.
} CropRect;

THUMBOR_INLINE CropRect CropRectMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right) {
    CropRect rect = {top, left, bottom, right};
    return rect;
}

typedef struct ResizeSize {
    int width, height;  // specify amount to inset (positive) for each of the edges.
} ResizeSize;

THUMBOR_INLINE ResizeSize ResizeSizeMake(int width, int height) {
    ResizeSize size; size.width = width; size.height = height; return size;
}

/**
 Original size for image width or height.
 */
THUMBOR_EXTERN const int THUMBOR_ORIGINAL_SIZE;

@interface OCThumborURLBuilder : NSObject

@property (nonatomic, strong, readonly) NSString *host;
@property (nonatomic, strong, readonly) NSString *key;
@property (nonatomic, strong, readonly) NSString *image;

@property (nonatomic, assign, readonly) BOOL hasCrop;
@property (nonatomic, assign, readonly) BOOL hasResize;
@property (nonatomic, assign, readonly) BOOL hasTrim;

@property (nonatomic, assign) ResizeSize resizeSize;
@property (nonatomic, assign) BOOL flipVertically;
@property (nonatomic, assign) BOOL flipHorizontally;
@property (nonatomic, assign) BOOL fitIn;

@property (nonatomic, assign) CropRect cropRect;
@property (nonatomic, assign) VerticalAlign verticalAlign;
@property (nonatomic, assign) HorizontalAlign horizontalAlign;
@property (nonatomic, assign) BOOL smart;

@property (nonatomic, assign) TrimPixelColor trimPixelColor;
@property (nonatomic, assign) int trimColorTolerance;

@property (nonatomic, assign) BOOL legacy;

@property (nonatomic, strong) NSArray *filter;

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
+ (NSString *)brightnessFilter:(int)amount;

/**
 The filter increases or decreases the image contrast.
 
 @param amount -100 to 100 - The amount (in %) to change the image contrast. Positive numbers increase contrast and negative numbers decrease contrast.
 
 @throws NSInvalidArgumentException if amount is outside bounds.
 */
+ (NSString *)contrastFilter:(int)amount;

/**
 This filter adds noise to the image.
 
 @param amount 0 to 100 - The amount (in %) of noise to add to the image.
 
 @throws NSInvalidArgumentException if amount is outside bounds.
 */
+ (NSString *)noiseFilter:(int)amount;

/**
 This filter changes the overall quality of the JPEG image (does nothing for PNGs or GIFs).
 
 @param amount 0 to 100 - The quality level (in %) that the end image will feature.
 
 @throws NSInvalidArgumentException if amount is outside bounds.
 */
+ (NSString *)qualityFilter:(int)amount;

/**
 This filter changes the amount of color in each of the three channels.
 
 @param red   The amount of redness in the picture. Can range from -100 to 100 in percentage.
 @param green The amount of greenness in the picture. Can range from -100 to 100 in percentage.
 @param blue  The amount of blueness in the picture. Can range from -100 to 100 in percentage.
 
 @throws NSInvalidArgumentException if red, green, or blue are outside of bounds.
 */
+ (NSString *)colorFilterWithRed:(int)red withGreen:(int)green andBlue:(int)blue;

/**
 This filter adds rounded corners to the image using the white as the background.
 
 @param radius amount of pixels to use as radius.
 */
+ (NSString *)roundCornerFilter:(int)radius;

/**
 This filter adds rounded corners to the image using the specified color as the background.
 
 @param radius amount of pixels to use as radius.
 @param color  fill color for clipped region.
 */
+ (NSString *)roundCornerFilter:(int)radius withColor:(int)color;

/**
 This filter adds rounded corners to the image using the specified color as the background.
 
 @param radiusInner amount of pixels to use as radius.
 @param radiusOuter specifies the second value for the ellipse used for the radius. Use 0 for no value.
 @param color       fill color for clipped region.
 */
+ (NSString *)roundCornerFilter:(int)innerRadius withOuterRadius:(int)outerRadius andColor:(int)color;

/**
 This filter adds a watermark to the image.
 
 @param imageUrl
 
 @throws NSInvalidArgumentException if imageUrl is blank
 */
+ (NSString *)watermarkFilter:(NSString *)imageUrl;

/**
 This filter adds a watermark to the image.
 
 @param imageUrl
 @param x            Horizontal position that the watermark will be in. Positive numbers indicate position from the left and negative numbers indicate position from the right.
 @param y            Vertical position that the watermark will be in. Positive numbers indicate position from the top and negative numbers indicate position from the bottom.
 
 @throws NSInvalidArgumentException if imageUrl is blank
 */
+ (NSString *)watermarkFilter:(NSString *)imageUrl withX:(int)x andY:(int)y;

/**
 This filter adds a watermark to the image.
 
 @param imageUrl
 @param x            Horizontal position that the watermark will be in. Positive numbers indicate position from the left and negative numbers indicate position from the right.
 @param y            Vertical position that the watermark will be in. Positive numbers indicate position from the top and negative numbers indicate position from the bottom.
 @param transparency Watermark image transparency. Should be a number between 0 (fully opaque) and 100 (fully transparent).
 
 @throws NSInvalidArgumentException if imageUrl is blank or transparency is outside of bounds
 */
+ (NSString *)watermarkFilter:(NSString *)imageUrl withX:(int)x withY:(int)y andTransparency:(int)transparency;

/**
 This filter adds a watermark to the image.
 
 @param builder
 
 @throws NSInvalidArgumentException if builder is nil
 */
+ (NSString *)watermarkFilterWithBuilder:(OCThumborURLBuilder *)builder;

/**
 This filter adds a watermark to the image.
 
 @param builder
 @param x            Horizontal position that the watermark will be in. Positive numbers indicate position from the left and negative numbers indicate position from the right.
 @param y            Vertical position that the watermark will be in. Positive numbers indicate position from the top and negative numbers indicate position from the bottom.
 
 @throws NSInvalidArgumentException if builder is nil
 */
+ (NSString *)watermarkFilterWithBuilder:(OCThumborURLBuilder *)builder withX:(int)x andY:(int)y;

/**
 This filter adds a watermark to the image.
 
 @param builder      
 @param x            Horizontal position that the watermark will be in. Positive numbers indicate position from the left and negative numbers indicate position from the right.
 @param y            Vertical position that the watermark will be in. Positive numbers indicate position from the top and negative numbers indicate position from the bottom.
 @param transparency Watermark image transparency. Should be a number between 0 (fully opaque) and 100 (fully transparent).
 
 @throws NSInvalidArgumentException if builder is nil
 */
+ (NSString *)watermarkFilterWithBuilder:(OCThumborURLBuilder *)builder withX:(int)x withY:(int)y andTransparency:(int)transparency;

/**
 This filter enhances apparent sharpness of the image. It's heavily based on Marco Rossini's excellent Wavelet sharpen GIMP plugin. Check http://registry.gimp.org/node/9836 for details about how it work.
 
 @param amount        Sharpen amount. Typical values are between 0.0 and 10.0.
 @param radius        Sharpen radius. Typical values are between 0.0 and 2.0.
 @param luminanceOnly Sharpen only luminance channel.
 */
+ (NSString *)sharpenFilter:(double)amount withRadius:(double)radius andLuminanceOnly:(BOOL)luminanceOnly;

/**
 This filter permit to return an image sized exactly as requested wherever is its ratio by filling with chosen color the missing parts. Usually used with "fit-in" or "adaptive-fit-in"
 */
+ (NSString *)fillFilter:(int)color;

/**
 Specify the output format of the image.
 
 @see ThumborImageFormat
 */
+ (NSString *)formatFilter:(ImageFormat)format;

/**
 This filter uses a 9-patch to overlay the image.
 
 @param imageUrl Watermark image URL. It is very important to understand that the same image loader that Thumbor uses will be used here.
 */
+ (NSString *)frameFilter:(NSString *)imageUrl;

/**
 This filter strips the ICC profile from the image.
 */
+ (NSString *)stripiccFilter;

/**
 This filter changes the image to grayscale.
 */
+ (NSString *)grayscaleFilter;

/**
 This filter equalizes the color distribution in the image.
 */
+ (NSString *)equalizeFilter;

@end

#pragma mark - Shorthands for filter methods

#define brightness(amount)                              [OCThumborURLBuilder brightnessFilter:amount]
#define contrast(amount)                                [OCThumborURLBuilder contrastFilter:amount]
#define noise(amount)                                   [OCThumborURLBuilder noiseFilter:amount]
#define quality(amount)                                 [OCThumborURLBuilder qualityFilter:amount]
#define rgb(red,green,blue)                             [OCThumborURLBuilder colorFilterWithRed:red withGreen:green andBlue:blue]
#define roundCorner(radius)                             [OCThumborURLBuilder roundCornerFilter:radius]
#define roundCornerC(radius,color)                      [OCThumborURLBuilder roundCornerFilter:radius withColor:color]
#define roundCornerOC(radius,outerRadius,color)         [OCThumborURLBuilder roundCornerFilter:radius withOuterRadius:outerRadius andColor:color]
#define watermark(image)                                [OCThumborURLBuilder watermarkFilter:image]
#define watermarkXY(image,x,y)                          [OCThumborURLBuilder watermarkFilter:image withX:x andY:y]
#define watermarkXYA(image,x,y,transparency)            [OCThumborURLBuilder watermarkFilter:image withX:x withY:y andTransparency:transparency]
#define watermarkB(builder)                             [OCThumborURLBuilder watermarkFilterWithBuilder:builder]
#define watermarkBXY(builder,x,y)                       [OCThumborURLBuilder watermarkFilterWithBuilder:builder withX:x andY:y]
#define watermarkBXYA(builder,x,y,transparency)         [OCThumborURLBuilder watermarkFilterWithBuilder:builder withX:x withY:y andTransparency:transparency]
#define sharpen(amount,radius,luminancyOnly)            [OCThumborURLBuilder sharpenFilter:amount withRadius:radius andLuminanceOnly:luminancyOnly]
#define fill(color)                                     [OCThumborURLBuilder fillFilter:color]
#define format(image)                                   [OCThumborURLBuilder formatFilter:image]
#define frame(image)                                    [OCThumborURLBuilder frameFilter:image]
#define stripicc                                        [OCThumborURLBuilder stripiccFilter]
#define grayscale                                       [OCThumborURLBuilder grayscaleFilter]
#define equalize                                        [OCThumborURLBuilder equalizeFilter]