# JCR6 for Turbo Pascal


This will be a small unit which allows the JCR6 format to be read by Turbo Pascal. A few notes are in order, since DOS programs are not blessed with lots of memory at their disposal, and therefore this version will lack a lot of functionality.
- JCR6 is a modular format in order for extensibility. Only the basis will be used.
- JCR6 will not pre-load the File Table, but will have to search through it on every file it loads. This is time-eating, I know, but saves RAM and in DOS, that is kinda vital.
- Now I am very positive about it that it will be possible to support zlib and lzma in DOS, but to spare the memory, I won't support that, nor the possibility to add drivers for that. Sorry!
- I am planning to support Jeroen's eXtremely Simplistic Repeatative Character Compression Algorithm. As a matter of fact I build that into the Go version of JCR6 *exactly* for this purpose. The extra memory it will need for decompression is minimal.
- No I won't allow this version of JCR6 to load alternate formats, like WAD. More trouble than it's worth, and I don't plan to use that in my Pascal projects anyway.
- Patching will NOT be supported
- So neither will IMPORT and REQUIRE tags work properly.
- By default strings are limited to 255 characters in Turbo Pascal. Anything longer than that will be truncated, although this will be rare.
- Fields in the file table not needed will be ignored
- And comments in a JCR6 file will be ignored too.
- I cannot rule out writing a JCR6 file will be possible in Turbo Pascal, but if I will support it, it will not use any kind of compression at all, not even JXSRCCA.
- I recommand against using this source code in modern Pascal compilers. It may compile (especially in Free Pascal when set to Turbo Pascal mode), but to be frank, I'm sure that since modern Pascal compilers are written for a far better hardware architechture, writing a unit that offers full functionality of JCR6 would be by far more fruitful. ;)


