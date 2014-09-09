## subs2anki
Simple perl script for generating an Anki deck from video and subtitle files. Currently, only SubStation Alpha (SSA) subs are supported. FFmpeg is required!

The script parses the subs and generates screenshots and audio clips for each piece of dialogue. Similar in functionality to subs2srs for Windows.

*Note: All assets will be generated in the current working directory the script runs in. For larger sources, this can result in thousands of files, so be prepared!*

**Usage**

``` sh
$ git clone https://github.com/haxie/subs2anki.git
$ cd subs2anki 
$ chmod +x subs2anki.pl
$ ./subs2anki.pl -s subtitle.ass -v video_file.mp4 -o deck.txt
```

**Sample**

![Sample Anki Card](http://hax.cm/e4.jpg "Sample Anki card")
