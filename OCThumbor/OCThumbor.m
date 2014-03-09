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

@implementation OCThumborURLBuilder {
    NSMutableArray *_filters;
}

- (id)initWithHost:(NSString *)host key:(NSString *)key image:(NSString *)image {
    self = [super init];
    if (self) {
        _host = host;
        _key = key;
        _image = image;
        
        _cropVerticalAlign = ThumborVerticalAlignNone;
        _cropHorizontalAlign = ThumborHorizontalAlignNone;
        _trimPixelColor = ThumborTrimPixelColorNone;
    }
    return self;
}

#pragma mark - Property Methods

- (instancetype)resizeWidth:(int)width height:(int)height {
    if (width < 0 && width != THUMBOR_ORIGINAL_SIZE) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Width must be a positive number." userInfo:nil];
    }
    if (height < 0 && height != THUMBOR_ORIGINAL_SIZE) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Height must be a positive number." userInfo:nil];
    }
    if (width == 0 && height == 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Both width and height must not be zero." userInfo:nil];
    }
    _hasResize = true;
    _resizeWidth = width;
    _resizeHeight = height;
    return self;
}

- (instancetype)flipVertically {
    if (!_hasResize) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Image must be resized first in order to flip." userInfo:nil];
    }
    
    _hasFlipVertically = YES;
    return self;
}

- (instancetype)flipHorizontally {
    if (!_hasResize) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Image must be resized first in order to flip." userInfo:nil];
    }
    
    _hasFlipHorizontally = YES;
    return self;
}

- (instancetype)fitIn {
    if (!_hasResize) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Image must be resized first in order to apply 'fit-in'." userInfo:nil];
    }
    
    _hasFitIn = YES;
    return self;
}

- (instancetype)cropTop:(int)top left:(int)left right:(int)bottom bottom:(int)right {
    if (top < 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Top must be greater or equal to zero." userInfo:nil];
    }
    if (left < 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Left must be greater or equal to zero." userInfo:nil];
    }
    if (bottom < 1 || bottom <= top) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Bottom must be greater than zero and top." userInfo:nil];
    }
    if (right < 1 || right <= left) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Right must be greater than zero and left." userInfo:nil];
    }
    _hasCrop = YES;
    _cropTop = top;
    _cropLeft = left;
    _cropBottom = bottom;
    _cropRight = right;
    return self;
}

- (instancetype)verticalAlign:(ThumborVerticalAlign)verticalAlign {
    if (!_hasCrop) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Image must be cropped first in order to align." userInfo:nil];
    }
    
    _cropVerticalAlign = verticalAlign;
    
    return self;
}

- (NSString *)stringFromVerticalAlign:(ThumborVerticalAlign)verticalAlign {
    switch (verticalAlign) {
        case ThumborVerticalAlignTop:
            return VERTICAL_ALIGN_TOP;
            break;
        case ThumborVerticalAlignMiddle:
            return VERTICAL_ALIGN_MIDDLE;
            break;
        case ThumborVerticalAlignBottom:
            return VERTICAL_ALIGN_BOTTOM;
            break;
        default:
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"invalid value for vertical align" userInfo:nil];
            break;
    }
}

- (instancetype)horizontalAlign:(ThumborHorizontalAlign)horizontalAlign {
    if (!_hasCrop) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Image must be cropped first in order to align." userInfo:nil];
    }
    
    _cropHorizontalAlign = horizontalAlign;
    
    return self;
}

- (NSString *)stringFromHorizontalAlign:(ThumborHorizontalAlign)horizontalAlign {
    switch (horizontalAlign) {
        case ThumborHorizontalAlignLeft:
            return HORIZONTAL_ALIGN_LEFT;
            break;
        case ThumborHorizontalAlignCenter:
            return HORIZONTAL_ALIGN_CENTER;
            break;
        case ThumborHorizontalAlignRight:
            return HORIZONTAL_ALIGN_RIGHT;
            break;
        default:
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"invalid value for horizontal align" userInfo:nil];
            break;
    }
}

- (instancetype)alignVertically:(ThumborVerticalAlign)verticalAlign horizontally:(ThumborHorizontalAlign)horizontalAlign {
    return [[self verticalAlign:verticalAlign] horizontalAlign:horizontalAlign];
}

- (instancetype)smart {
    if (!_hasCrop) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Image must be cropped first in order to align." userInfo:nil];
    }
    _isSmart = YES;
    return self;
}

- (instancetype)trim {
    return [self trim:ThumborTrimPixelColorNone withTolerance:0];
}

- (instancetype)trim:(ThumborTrimPixelColor)trimColor {
    return [self trim:trimColor withTolerance:0];
}

- (instancetype)trim:(ThumborTrimPixelColor)trimColor withTolerance:(int)tolerance {
    if (tolerance < 0 || tolerance > 442) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Color tolerance must be between 0 and 442." userInfo:nil];
    }
    if (tolerance > 0 && trimColor == ThumborTrimPixelColorNone) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Trim pixel color value must be valid." userInfo:nil];
    }
    
    _isTrim = YES;
    _trimPixelColor = trimColor;
    _trimColorTolerance = tolerance;
    
    return self;
}

- (NSString *)stringFromTrimPixelColor:(ThumborTrimPixelColor)trimColor {
    switch (trimColor) {
        case ThumborTrimPixelColorTopLeft:
            return TRIM_PIXEL_COLOR_TOP_LEFT;
            break;
        case ThumborTrimPixelColorBottomRight:
            return TRIM_PIXEL_COLOR_BOTTOM_RIGHT;
        default:
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Invalid value for trim color" userInfo:nil];
            break;
    }
}

- (instancetype)legacy {
    _isLegacy = true;
    return self;
}

- (instancetype)filter:(NSString *)filterValue, ... {
    NSMutableArray *filters = [[NSMutableArray alloc] init];
    
    va_list args;
    va_start(args, filterValue);
    for (NSString *arg = filterValue; arg != nil; arg = va_arg(args, NSString*)) {
        [filters addObject:arg];
    }
    va_end(args);
    
    return [self filterFromArray:[filters copy]];
}

- (instancetype)filterFromArray:(NSArray *)filters {
    if (filters.count == 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"You must provide at least one filter." userInfo:nil];
    }
    if (_filters == nil) {
        _filters = [[NSMutableArray alloc] initWithCapacity:filters.count];
    }
    for (NSString *filter in filters) {
        if (filter.length == 0) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Filter must not be blank." userInfo:nil];
        }
        [_filters addObject:filter];
    }
    return self;
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
    
    BOOL legacy = _isLegacy;
    
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
    
    if (_isTrim) {
        [builder appendString:THUMBOR_PART_TRIM];
        if (_trimPixelColor != ThumborTrimPixelColorNone) {
            [builder appendFormat:@":%@", [self stringFromTrimPixelColor:_trimPixelColor]];
            if (_trimColorTolerance > 0) {
                [builder appendFormat:@":%d", _trimColorTolerance];
            }
        }
        [builder appendString:@"/"];
    }
    
    if (_hasCrop) {
        [builder appendFormat:@"%dx%d:%dx%d", _cropLeft, _cropTop, _cropRight, _cropBottom];
        
        if (_isSmart) {
            [builder appendFormat:@"/%@", THUMBOR_PART_SMART];
        } else {
            if (_cropHorizontalAlign != ThumborHorizontalAlignNone) {
                [builder appendFormat:@"/%@", [self stringFromHorizontalAlign:_cropHorizontalAlign]];
            }
            if (_cropVerticalAlign != ThumborHorizontalAlignNone) {
                [builder appendFormat:@"/%@", [self stringFromVerticalAlign:_cropVerticalAlign]];
            }
        }
        [builder appendString:@"/"];
    }
    
    if (_hasResize) {
        if (_hasFitIn) {
            [builder appendFormat:@"%@/", THUMBOR_PART_FIT_IN];
        }
        if (_hasFlipHorizontally) {
            [builder appendString:@"-"];
        }
        if (_resizeWidth == THUMBOR_ORIGINAL_SIZE) {
            [builder appendString:@"orig"];
        } else {
            [builder appendFormat:@"%d", _resizeWidth];
        }
        [builder appendString:@"x"];
        if (_hasFlipVertically) {
            [builder appendString:@"-"];
        }
        if (_resizeHeight == THUMBOR_ORIGINAL_SIZE) {
            [builder appendString:@"orig"];
        } else {
            [builder appendFormat:@"%d", _resizeHeight];
        }
        [builder appendString:@"/"];
    }
    
    if (_filters != nil) {
        [builder appendString:THUMBOR_PART_FILTERS];
        for (NSString *filter in _filters) {
            [builder appendFormat:@":%@", filter];
        }
        [builder appendString:@"/"];
    }
    
    NSString *image = _isLegacy ? _image : _image;
    
    [builder appendString:image];
    
    return builder;
}

#pragma mark - Filter Methods

+ (NSString *)brightness:(int)amount {
    if (amount < -100 || amount > 100) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Amount must be between -100 and 100, inclusive." userInfo:nil];
    }
    return [NSString stringWithFormat:@"%@(%d)", THUMBOR_FILTER_BRIGHTNESS, amount];
}

+ (NSString *)contrast:(int)amount {
    if (amount < -100 || amount > 100) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Amount must be between -100 and 100, inclusive." userInfo:nil];
    }
    return [NSString stringWithFormat:@"%@(%d)", THUMBOR_FILTER_CONTRAST, amount];
}

+ (NSString *)noise:(int)amount {
    if (amount < 0 || amount > 100) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Amount must be between 0 and 100, inclusive." userInfo:nil];
    }
    return [NSString stringWithFormat:@"%@(%d)", THUMBOR_FILTER_NOISE, amount];
}

+ (NSString *)quality:(int)amount {
    if (amount < 0 || amount > 100) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Amount must be between 0 and 100, inclusive." userInfo:nil];
    }
    return [NSString stringWithFormat:@"%@(%d)", THUMBOR_FILTER_QUALITY, amount];
}

+ (NSString *)red:(int)red green:(int)green blue:(int)blue {
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

+ (NSString *)roundCorner:(int)radius {
    return [OCThumborURLBuilder roundCorner:radius color:0xFFFFFF];
}

+ (NSString *)roundCorner:(int)radius color:(int)color {
    return [OCThumborURLBuilder roundCorner:radius radiusOuter:0 color:color];
}

+ (NSString *)roundCorner:(int)radiusInner radiusOuter:(int)radiusOuter color:(int)color {
    if (radiusInner < 1) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Radius must be greater than zero." userInfo:nil];
    }
    if (radiusOuter < 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Outer radius must be greater than or equal to zero." userInfo:nil];
    }
    
    NSMutableString *builder = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@(%d", THUMBOR_FILTER_ROUND_CORNER, radiusInner]];
    if (radiusOuter > 0) {
        [builder appendFormat:@"|%d", radiusOuter];
    }
    
    int r = (color & 0xFF0000) >> 16;
    int g = (color & 0xFF00) >> 8;
    int b = color & 0xFF;
    
    [builder appendFormat:@",%d,%d,%d)", r, g, b];
    
    return [builder copy];
}

+ (NSString *)watermark:(NSString *)imageUrl {
    return [OCThumborURLBuilder watermark:imageUrl x:0 y:0];
}

+ (NSString *)watermark:(NSString *)imageUrl x:(int)x y:(int)y {
    return [OCThumborURLBuilder watermark:imageUrl x:x y:y transparency:0];
}

+ (NSString *)watermark:(NSString *)imageUrl x:(int)x y:(int)y transparency:(int)transparency {
    if (imageUrl.length == 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Image URL must not be blank." userInfo:nil];
    }
    if (transparency < 0 || transparency > 100) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Transparency must be between 0 and 100, inclusive." userInfo:nil];
    }
    return [NSString stringWithFormat:@"%@(%@,%d,%d,%d)", THUMBOR_FILTER_WATERMARK, imageUrl, x, y, transparency];
}

+ (NSString *)watermarkWithBuilder:(OCThumborURLBuilder *)builder x:(int)x y:(int)y {
    if (builder == nil) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Builder must not be null." userInfo:nil];
    }
    return [OCThumborURLBuilder watermark:[builder toUrl] x:x y:y transparency:0];
}

+ (NSString *)watermarkWithBuilder:(OCThumborURLBuilder *)builder {
    return [OCThumborURLBuilder watermarkWithBuilder:builder x:0 y:0];
}

+ (NSString *)watermarkWithBuilder:(OCThumborURLBuilder *)builder x:(int)x y:(int)y transparency:(int)transparency {
    if (builder == nil) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Builder must not be null." userInfo:nil];
    }
    return [OCThumborURLBuilder watermark:[builder toUrl] x:x y:y transparency:transparency];
}

+ (NSString *)sharpen:(double)amount radius:(double)radius luminanceOnly:(BOOL)luminanceOnly {
    NSString *luminance = luminanceOnly ? @"true" : @"false";
    return [NSString stringWithFormat:@"%@(%.1f,%.1f,%@)", THUMBOR_FILTER_SHARPEN, amount, radius, luminance];
}

+ (NSString *)fill:(int)color {
    int colorCode = color & 0xFFFFFF; // Strip alpha
    return [NSString stringWithFormat:@"%@(%x)", THUMBOR_FILTER_FILL, colorCode];
}

+ (NSString *)format:(ThumborImageFormat)format {
    NSString *formatString;
    switch (format) {
        case ThumborImageFormatGif:
            formatString = IMAGE_FORMAT_GIF;
            break;
        case ThumborImageFormatJpeg:
            formatString = IMAGE_FORMAT_JPEG;
            break;
        case ThumborImageFormatPng:
            formatString = IMAGE_FORMAT_PNG;
            break;
        case ThumborImageFormatWebp:
            formatString = IMAGE_FORMAT_WEBP;
            break;
        default:
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Image format is invalid" userInfo:nil];
            break;
    }
    
    return [NSString stringWithFormat:@"%@(%@)", THUMBOR_FILTER_FORMAT, formatString];
}

+ (NSString *)frame:(NSString *)imageUrl {
    if (imageUrl.length == 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Image URL must not be blank." userInfo:nil];
    }
    return [NSString stringWithFormat:@"%@(%@)", THUMBOR_FILTER_FRAME, imageUrl];
}

+ (NSString *)stripicc {
    return [NSString stringWithFormat:@"%@()", THUMBOR_FILTER_STRIP_ICC];
}

+ (NSString *)grayscale {
    return [NSString stringWithFormat:@"%@()", THUMBOR_FILTER_GRAYSCALE];
}

+ (NSString *)equalize {
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
