//
//  OCThumbor.m
//  
//
//  Created by Daniel Heckrath on 08.03.14.
//
//

#import "OCThumbor.h"

#import <CocoaSecurity/CocoaSecurity.h>

NSString * const THUMBOR_PREFIX_UNSAFE          = @"unsafe/";
NSString * const THUMBOR_PREFIX_META            = @"meta/";
NSString * const THUMBOR_PART_SMART             = @"smart";
NSString * const THUMBOR_PART_TRIM              = @"trim";
NSString * const THUMBOR_PART_FIT_IN            = @"fit-in";
NSString * const THUMBOR_PART_FILTERS           = @"filters";
NSString * const THUMBOR_FILTER_BRIGHTNESS      = @"brightness";
NSString * const THUMBOR_FILTER_CONTRAST        = @"contrast";
NSString * const THUMBOR_FILTER_NOISE           = @"noise";
NSString * const THUMBOR_FILTER_QUALITY         = @"quality";
NSString * const THUMBOR_FILTER_RGB             = @"rgb";
NSString * const THUMBOR_FILTER_ROUND_CORNER    = @"round_corner";
NSString * const THUMBOR_FILTER_WATERMARK       = @"watermark";
NSString * const THUMBOR_FILTER_SHARPEN         = @"sharpen";
NSString * const THUMBOR_FILTER_FILL            = @"fill";
NSString * const THUMBOR_FILTER_FORMAT          = @"format";
NSString * const THUMBOR_FILTER_FRAME           = @"frame";
NSString * const THUMBOR_FILTER_STRIP_ICC       = @"strip_icc";
NSString * const THUMBOR_FILTER_GRAYSCALE       = @"grayscale";
NSString * const THUMBOR_FILTER_EQUALIZE        = @"equalize";

/** Original size for image width or height. **/

const int THUMBOR_ORIGINAL_SIZE = INT_MIN;

NSString * const HORIZONTAL_ALIGN_LEFT      = @"left";
NSString * const HORIZONTAL_ALIGN_CENTER    = @"center";
NSString * const HORIZONTAL_ALIGN_RIGHT     = @"right";

NSString * const VERTICAL_ALIGN_TOP     = @"top";
NSString * const VERTICAL_ALIGN_MIDDLE  = @"middle";
NSString * const VERTICAL_ALIGN_BOTTOM  = @"bottom";

NSString * const TRIM_PIXEL_COLOR_TOP_LEFT      = @"top-left";
NSString * const TRIM_PIXEL_COLOR_BOTTOM_RIGHT  = @"bottom-right";

NSString * const IMAGE_FORMAT_GIF   = @"gif";
NSString * const IMAGE_FORMAT_JPEG  = @"jpeg";
NSString * const IMAGE_FORMAT_PNG   = @"png";
NSString * const IMAGE_FORMAT_WEBP  = @"webp";

@interface OCThumborURLBuilder ()

- (id)initWithHost:(NSString *)host key:(NSString *)key image:(NSString *)image;

@end

@implementation OCThumborURLBuilder

- (id)initWithHost:(NSString *)host key:(NSString *)key image:(NSString *)image {
    self = [super init];
    if (self) {
        _host = host;
        _key = key;
        _image = image;
        
        _verticalAlign = VerticalAlignNone;
        _horizontalAlign = HorizontalAlignNone;
        _trimPixelColor = TrimPixelColorNone;
    }
    return self;
}

#pragma mark - Property Methods

- (void)setResizeSize:(ResizeSize)size {
    if (size.width < 0 && size.width != THUMBOR_ORIGINAL_SIZE) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Width must be a positive number." userInfo:nil];
    }
    if (size.height < 0 && size.height != THUMBOR_ORIGINAL_SIZE) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Height must be a positive number." userInfo:nil];
    }
    if (size.width == 0 && size.height == 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Both width and height must not be zero." userInfo:nil];
    }
    _hasResize = true;
    _resizeSize = size;
}

- (void)setFlipVertically:(BOOL)flipVertically {
    if (flipVertically && !_hasResize) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Image must be resized first in order to flip." userInfo:nil];
    }
    
    _flipVertically = flipVertically;
}

- (void)setFlipHorizontally:(BOOL)flipHorizontally {
    if (flipHorizontally && !_hasResize) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Image must be resized first in order to flip." userInfo:nil];
    }
    
    _flipHorizontally = flipHorizontally;
}

- (void)setFitIn:(BOOL)fitIn {
    if (fitIn && !_hasResize) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Image must be resized first in order to apply 'fit-in'." userInfo:nil];
    }
    
    _fitIn = fitIn;
}

- (void)setCropRect:(CropRect)cropRect {
    if (cropRect.top < 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Top must be greater or equal to zero." userInfo:nil];
    }
    if (cropRect.left < 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Left must be greater or equal to zero." userInfo:nil];
    }
    if (cropRect.bottom < 1 || cropRect.bottom <= cropRect.top) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Bottom must be greater than zero and top." userInfo:nil];
    }
    if (cropRect.right < 1 || cropRect.right <= cropRect.left) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Right must be greater than zero and left." userInfo:nil];
    }
    
    _hasCrop = YES;
    _cropRect = cropRect;
}

- (void)setVerticalAlign:(VerticalAlign)verticalAlign {
    if (verticalAlign != VerticalAlignNone && !_hasResize) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Image must be cropped first in order to align." userInfo:nil];
    }
    
    _verticalAlign = verticalAlign;
}

- (NSString *)stringFromVerticalAlign:(VerticalAlign)verticalAlign {
    switch (verticalAlign) {
        case VerticalAlignTop:
            return VERTICAL_ALIGN_TOP;
            break;
        case VerticalAlignMiddle:
            return VERTICAL_ALIGN_MIDDLE;
            break;
        case VerticalAlignBottom:
            return VERTICAL_ALIGN_BOTTOM;
            break;
        default:
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"invalid value for vertical align" userInfo:nil];
            break;
    }
}

- (void)setHorizontalAlign:(HorizontalAlign)horizontalAlign {
    if (horizontalAlign != HorizontalAlignNone && !_hasResize) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Image must be cropped first in order to align." userInfo:nil];
    }
    
    _horizontalAlign = horizontalAlign;
}

- (NSString *)stringFromHorizontalAlign:(HorizontalAlign)horizontalAlign {
    switch (horizontalAlign) {
        case HorizontalAlignLeft:
            return HORIZONTAL_ALIGN_LEFT;
            break;
        case HorizontalAlignCenter:
            return HORIZONTAL_ALIGN_CENTER;
            break;
        case HorizontalAlignRight:
            return HORIZONTAL_ALIGN_RIGHT;
            break;
        default:
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"invalid value for horizontal align" userInfo:nil];
            break;
    }
}

- (void)setSmart:(BOOL)smart {
    if (smart && !_hasResize) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Image must be cropped first in order to align." userInfo:nil];
    }
    
    _smart = smart;
}

- (void)setTrimPixelColor:(TrimPixelColor)trimPixelColor {
    _trimPixelColor = trimPixelColor;
    _hasTrim = (trimPixelColor != TrimPixelColorNone);
    
    if (trimPixelColor == TrimPixelColorNone) {
        _trimColorTolerance = 0;
    }
}

- (void)setTrimColorTolerance:(int)trimColorTolerance {
    if (trimColorTolerance < 0 || trimColorTolerance > 442) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Color tolerance must be between 0 and 442." userInfo:nil];
    }
    if (trimColorTolerance > 0 && _trimPixelColor == TrimPixelColorNone) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Trim pixel color value must be valid." userInfo:nil];
    }
    
    _trimColorTolerance = trimColorTolerance;
}

- (NSString *)stringFromTrimPixelColor:(TrimPixelColor)trimColor {
    switch (trimColor) {
        case TrimPixelColorTopLeft:
            return TRIM_PIXEL_COLOR_TOP_LEFT;
            break;
        case TrimPixelColorBottomRight:
            return TRIM_PIXEL_COLOR_BOTTOM_RIGHT;
        default:
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Invalid value for trim color" userInfo:nil];
            break;
    }
}

- (void)setFilter:(NSArray *)filter {
    // validate that no filter string is blank
    for (NSString *filterString in filter) {
        if (filterString.length == 0) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Filter must not be blank." userInfo:nil];
        }
    }
    
    _filter = filter;
}

- (NSString *)toUrl {
    return (_key == nil) ? [self toUrlUnsafe] : [self toUrlSafe];
}

- (NSString *)toUrlUnsafe {
    return [NSString stringWithFormat:@"%@%@%@", _host, THUMBOR_PREFIX_UNSAFE, [self assembleConfig:NO]];
}

- (NSString *)toUrlSafe {
    if (_key == nil) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot build safe URL without a key." userInfo:nil];
    }
    
    BOOL legacy = _legacy;
    
    NSMutableString *config = [self assembleConfig:NO];
    
    CocoaSecurityResult *encrypted = legacy ? [CocoaSecurity aesEncrypt:config key:_key] : [CocoaSecurity hmacSha1:config hmacKey:_key];
    NSString *encoded = encrypted.base64;
    
    // make encoded part url safe
    encoded = [encoded stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    encoded = [encoded stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    
    NSString *suffix = legacy ? _image : config;
    return [NSString stringWithFormat:@"%@%@/%@", _host, encoded, suffix];
}

- (NSString *)toMeta {
    return (_key == nil) ? [self toMetaUnsafe] : [self toMetaSafe];
}

- (NSString *)toMetaUnsafe {
    return [NSString stringWithFormat:@"%@%@", _host, [self assembleConfig:YES]];
}

- (NSString *)toMetaSafe {
    if (_key == nil) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot build safe URL without a key." userInfo:nil];
    }
    
    NSMutableString *config = [self assembleConfig:NO];
    
    CocoaSecurityResult *encrypted = [CocoaSecurity hmacSha1:config hmacKey:_key];
    NSString *encoded = encrypted.base64;
    return [NSString stringWithFormat:@"%@%@/%@", _host, encoded, config];
}

- (NSMutableString *)assembleConfig:(BOOL)meta {
    NSMutableString *builder = [[NSMutableString alloc] init];
    
    if (meta) {
        [builder appendString:THUMBOR_PREFIX_META];
    }
    
    if (_hasTrim) {
        [builder appendString:THUMBOR_PART_TRIM];
        if (_trimPixelColor != TrimPixelColorNone) {
            [builder appendFormat:@":%@", [self stringFromTrimPixelColor:_trimPixelColor]];
            if (_trimColorTolerance > 0) {
                [builder appendFormat:@":%d", _trimColorTolerance];
            }
        }
        [builder appendString:@"/"];
    }
    
    if (_hasCrop) {
        [builder appendFormat:@"%dx%d:%dx%d/", _cropRect.left, _cropRect.top, _cropRect.right, _cropRect.bottom];
    }
    
    if (_hasResize) {
        if (_fitIn) {
            [builder appendFormat:@"%@/", THUMBOR_PART_FIT_IN];
        }
        if (_flipHorizontally) {
            [builder appendString:@"-"];
        }
        if (_resizeSize.width == THUMBOR_ORIGINAL_SIZE) {
            [builder appendString:@"orig"];
        } else {
            [builder appendFormat:@"%d", _resizeSize.width];
        }
        [builder appendString:@"x"];
        if (_flipVertically) {
            [builder appendString:@"-"];
        }
        if (_resizeSize.height == THUMBOR_ORIGINAL_SIZE) {
            [builder appendString:@"orig"];
        } else {
            [builder appendFormat:@"%d", _resizeSize.height];
        }
        if (_smart) {
            [builder appendFormat:@"/%@", THUMBOR_PART_SMART];
        } else {
            if (_horizontalAlign != HorizontalAlignNone) {
                [builder appendFormat:@"/%@", [self stringFromHorizontalAlign:_horizontalAlign]];
            }
            if (_verticalAlign != HorizontalAlignNone) {
                [builder appendFormat:@"/%@", [self stringFromVerticalAlign:_verticalAlign]];
            }
        }
        [builder appendString:@"/"];
    }
    
    if (_filter.count > 0) {
        [builder appendString:THUMBOR_PART_FILTERS];
        for (NSString *filter in _filter) {
            [builder appendFormat:@":%@", filter];
        }
        [builder appendString:@"/"];
    }
    
    NSString *image;
    if (_legacy) {
        CocoaSecurityResult *hashed = [CocoaSecurity md5:_image];
        image = hashed.hexLower;
    } else {
        image = _image;
    }
    
    [builder appendString:image];
    
    return builder;
}

#pragma mark - Filter Methods

+ (NSString *)brightnessFilter:(int)amount {
    if (amount < -100 || amount > 100) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Amount must be between -100 and 100, inclusive." userInfo:nil];
    }
    return [NSString stringWithFormat:@"%@(%d)", THUMBOR_FILTER_BRIGHTNESS, amount];
}

+ (NSString *)contrastFilter:(int)amount {
    if (amount < -100 || amount > 100) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Amount must be between -100 and 100, inclusive." userInfo:nil];
    }
    return [NSString stringWithFormat:@"%@(%d)", THUMBOR_FILTER_CONTRAST, amount];
}

+ (NSString *)noiseFilter:(int)amount {
    if (amount < 0 || amount > 100) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Amount must be between 0 and 100, inclusive." userInfo:nil];
    }
    return [NSString stringWithFormat:@"%@(%d)", THUMBOR_FILTER_NOISE, amount];
}

+ (NSString *)qualityFilter:(int)amount {
    if (amount < 0 || amount > 100) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Amount must be between 0 and 100, inclusive." userInfo:nil];
    }
    return [NSString stringWithFormat:@"%@(%d)", THUMBOR_FILTER_QUALITY, amount];
}

+ (NSString *)colorFilterWithRed:(int)red withGreen:(int)green andBlue:(int)blue {
    if (red < -100 || red > 100) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Red value must be between -100 and 100, inclusive." userInfo:nil];
    }
    if (green < -100 || green > 100) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Green value must be between -100 and 100, inclusive." userInfo:nil];
    }
    if (blue < -100 || blue > 100) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Blue value must be between -100 and 100, inclusive." userInfo:nil];
    }
    return [NSString stringWithFormat:@"%@(%d,%d,%d)", THUMBOR_FILTER_RGB, red, green, blue];
}

+ (NSString *)roundCornerFilter:(int)radius {
    return [OCThumborURLBuilder roundCornerFilter:radius withColor:0xFFFFFF];
}

+ (NSString *)roundCornerFilter:(int)radius withColor:(int)color {
    return [OCThumborURLBuilder roundCornerFilter:radius withOuterRadius:0 andColor:color];
}

+ (NSString *)roundCornerFilter:(int)innerRadius withOuterRadius:(int)outerRadius andColor:(int)color {
    if (innerRadius < 1) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Radius must be greater than zero." userInfo:nil];
    }
    if (outerRadius < 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Outer radius must be greater than or equal to zero." userInfo:nil];
    }
    
    NSMutableString *builder = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@(%d", THUMBOR_FILTER_ROUND_CORNER, innerRadius]];
    if (outerRadius > 0) {
        [builder appendFormat:@"|%d", outerRadius];
    }
    
    int r = (color & 0xFF0000) >> 16;
    int g = (color & 0xFF00) >> 8;
    int b = color & 0xFF;
    
    [builder appendFormat:@",%d,%d,%d)", r, g, b];
    
    return [builder copy];
}

+ (NSString *)watermarkFilter:(NSString *)imageUrl {
    return [OCThumborURLBuilder watermarkFilter:imageUrl withX:0 andY:0];
}

+ (NSString *)watermarkFilter:(NSString *)imageUrl withX:(int)x andY:(int)y {
    return [OCThumborURLBuilder watermarkFilter:imageUrl withX:x withY:y andTransparency:0];
}

+ (NSString *)watermarkFilter:(NSString *)imageUrl withX:(int)x withY:(int)y andTransparency:(int)transparency {
    if (imageUrl.length == 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Image URL must not be blank." userInfo:nil];
    }
    if (transparency < 0 || transparency > 100) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Transparency must be between 0 and 100, inclusive." userInfo:nil];
    }
    return [NSString stringWithFormat:@"%@(%@,%d,%d,%d)", THUMBOR_FILTER_WATERMARK, imageUrl, x, y, transparency];
}

+ (NSString *)watermarkFilterWithBuilder:(OCThumborURLBuilder *)builder {
    return [OCThumborURLBuilder watermarkFilterWithBuilder:builder withX:0 andY:0];
}

+ (NSString *)watermarkFilterWithBuilder:(OCThumborURLBuilder *)builder withX:(int)x andY:(int)y {
    if (builder == nil) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Builder must not be null." userInfo:nil];
    }
    return [OCThumborURLBuilder watermarkFilter:[builder toUrl] withX:x withY:y andTransparency:0];
}

+ (NSString *)watermarkFilterWithBuilder:(OCThumborURLBuilder *)builder withX:(int)x withY:(int)y andTransparency:(int)transparency {
    if (builder == nil) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Builder must not be null." userInfo:nil];
    }
    return [OCThumborURLBuilder watermarkFilter:[builder toUrl] withX:x withY:y andTransparency:transparency];
}

+ (NSString *)sharpenFilter:(double)amount withRadius:(double)radius andLuminanceOnly:(BOOL)luminanceOnly {
    NSString *luminance = luminanceOnly ? @"true" : @"false";
    return [NSString stringWithFormat:@"%@(%.1f,%.1f,%@)", THUMBOR_FILTER_SHARPEN, amount, radius, luminance];
}

+ (NSString *)fillFilter:(int)color {
    int colorCode = color & 0xFFFFFF; // Strip alpha
    return [NSString stringWithFormat:@"%@(%x)", THUMBOR_FILTER_FILL, colorCode];
}

+ (NSString *)formatFilter:(ImageFormat)format {
    NSString *formatString;
    switch (format) {
        case ImageFormatGif:
            formatString = IMAGE_FORMAT_GIF;
            break;
        case ImageFormatJpeg:
            formatString = IMAGE_FORMAT_JPEG;
            break;
        case ImageFormatPng:
            formatString = IMAGE_FORMAT_PNG;
            break;
        case ImageFormatWebp:
            formatString = IMAGE_FORMAT_WEBP;
            break;
        default:
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Image format is invalid" userInfo:nil];
            break;
    }
    
    return [NSString stringWithFormat:@"%@(%@)", THUMBOR_FILTER_FORMAT, formatString];
}

+ (NSString *)frameFilter:(NSString *)imageUrl {
    if (imageUrl.length == 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Image URL must not be blank." userInfo:nil];
    }
    return [NSString stringWithFormat:@"%@(%@)", THUMBOR_FILTER_FRAME, imageUrl];
}

+ (NSString *)stripiccFilter {
    return [NSString stringWithFormat:@"%@()", THUMBOR_FILTER_STRIP_ICC];
}

+ (NSString *)grayscaleFilter {
    return [NSString stringWithFormat:@"%@()", THUMBOR_FILTER_GRAYSCALE];
}

+ (NSString *)equalizeFilter {
    return [NSString stringWithFormat:@"%@()", THUMBOR_FILTER_EQUALIZE];
}

@end

@interface OCThumbor ()

- (id)initWithHost:(NSString *)host key:(NSString *)key;

@end

@implementation OCThumbor

#pragma mark - Class Methods

+ (instancetype)createWithHost:(NSString *)host {
    return [[OCThumbor alloc] initWithHost:host key:nil];
}

+ (instancetype)createWithHost:(NSString *)host key:(NSString *)key {
    if (key.length == 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Key must not be blank" userInfo:nil];
    }
    
    return [[OCThumbor alloc] initWithHost:host key:key];
}

#pragma mark - Instance Methods

- (id)initWithHost:(NSString *)host key:(NSString *)key {
    if (host.length == 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Host must not be blank" userInfo:nil];
    }
    self = [super init];
    if (self) {
        if (![host hasSuffix:@"/"]) {
            host = [host stringByAppendingString:@"/"];
        }
        
        _host = host;
        _key = key;
    }
    return self;
}

- (OCThumborURLBuilder *)buildImage:(NSString *)image {
    if (image.length == 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Image must not be blank" userInfo:nil];
    }
    
    return [[OCThumborURLBuilder alloc] initWithHost:_host key:_key image:image];
}

@end
