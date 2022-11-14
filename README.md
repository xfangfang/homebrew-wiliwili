# homebrew-wiliwili

This repo contains custom mpv and ffmpeg homebrew tap for wiliwili.

```
brew tab xfangfang/wiliwili
brew install mpv-wiliwili
```

### mpv-wiliwili.rb

Depends on ffmpeg-wiliwili instead of ffmpeg  
Does not depend on vapoursynth and yt-dlp


### ffmpeg-wiliwili.rb

Removed all encoding libraries  
Removed some of the decoding libraries which ffmpeg can natively decode  
