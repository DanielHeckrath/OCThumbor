OCThumbor - Objective-C Thumbor client
=========

Objective-C for the [Thumbor image service][1] which allows you to build URIs
in an expressive fashion using a fluent API.

This project is largely based on the [Pollexor Library][2] by Square Inc., which is a Thumbor client for JAVA.

Examples
--------
```objc
// Without encryption:
OCThumbor *thumbor = [OCThumbor createWithHost:@"http://example.com/"];

// With encryption:
OCThumbor *thumbor = [OCThumbor createWithHost:@"http://example.com/" key:@"key"];
```

```objc
OCThumborURLBuilder *builder = [thumbor buildImage:@"example.com/image.png"];
builder.resizeSize = ResizeSizeMake(48,48);
[builder toUrl];
// Produces: /unsafe/48x48/example.com/image.png

OCThumborURLBuilder *builder = [thumbor buildImage:@"example.com/image.png"];
builder.cropEdgeInsets = CropEdgeInsetsMake(10,10,90,90);
builder.resizeSize = ResizeSizeMake(40,40);
builder.smart = YES;
[builder toUrl];
// Produces: /unsafe/10x10:90x90/smart/40x40/example.com/image.png

OCThumborURLBuilder *builder = [thumbor buildImage:@"example.com/image.png"];
builder.cropEdgeInsets = CropEdgeInsetsMake(10,10,90,90);
builder.cropVerticalAlign = VerticalAlignBottom;
builder.cropHorizontalAlign = HorizontalAlignRight;
builder.resizeSize = ResizeSizeMake(40,40);
[builder toUrl];
// Produces: /unsafe/5x5:195x195/right/bottom/95x95/example.com/image.png

OCThumborURLBuilder *builder = [thumbor buildImage:@"example.com/background.png"];
builder.resizeSize = ResizeSizeMake(200,100);
builder.filter = @[roundCorner(10),quality(85)];
[builder toUrl];
// Produces: /unsafe/200x100/filters:round_corner(10,255,255,255):quality(85)/example.com/background.png
```

License
=======

    Copyright 2014 Daniel Heckrath

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

[1]: https://github.com/globocom/thumbor
[2]: http://square.github.io/pollexor/
