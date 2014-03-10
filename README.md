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
[builder resizeWidth:48 height:48];
[builder toUrl];
// Produces: /unsafe/48x48/example.com/image.png

OCThumborURLBuilder *builder = [thumbor buildImage:@"example.com/image.png"];
[builder cropTop:10 left:10 right:90 bottom:90];
[builder resizeWidth:40 height:40];
[builder smart];
[builder toUrl];
// Produces: /unsafe/10x10:90x90/smart/40x40/example.com/image.png

OCThumborURLBuilder *builder = [thumbor buildImage:@"example.com/image.png"];
[builder cropTop:5 left:5 right:195 bottom:195];
[builder resizeWidth:40 height:40];
[builder alignVertically:ThumborVerticalAlignBottom horizontally:ThumborHorizontalAlignRight];
[builder toUrl];
// Produces: /unsafe/5x5:195x195/right/bottom/95x95/example.com/image.png

OCThumborURLBuilder *builder = [thumbor buildImage:@"example.com/background.png"];
[builder resizeWidth:200 height:100];
[builder filter:
	th_roundCorner(10),
	th_quality(85),
	nil
];
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
