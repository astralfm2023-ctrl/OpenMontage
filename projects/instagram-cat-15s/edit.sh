#!/usr/bin/env bash
# Rebuild the 15s Instagram edit (with captions) from the original 24.4s clip.
# Usage: ./edit.sh <source.mp4>
set -euo pipefail
SRC="$1"
cd "$(dirname "$0")"
mkdir -p renders
ffmpeg -y -i "$SRC" -filter_complex "\
[0:v]trim=0.6:3.0,setpts=PTS-STARTPTS[a];\
[0:v]trim=3.0:5.2,setpts=PTS-STARTPTS[b];\
[0:v]trim=5.8:9.2,setpts=PTS-STARTPTS[c];\
[0:v]trim=16.4:19.9,setpts=PTS-STARTPTS[d];\
[0:v]trim=20.55:24.34,setpts=PTS-STARTPTS[e];\
[c][d]xfade=transition=fade:duration=0.3:offset=3.1[cd];\
[a][b][cd][e]concat=n=4:v=1:a=0,fps=30,format=yuv420p,ass=captions.ass:fontsdir=assets/fonts[v];\
[0:a]atrim=0.6:15.6,asetpts=PTS-STARTPTS,afade=t=in:d=0.15,afade=t=out:st=14.2:d=0.8[au]" \
  -map "[v]" -map "[au]" -t 15 -c:v libx264 -preset slow -crf 18 -profile:v high -r 30 \
  -c:a aac -b:a 192k -ar 44100 -movflags +faststart renders/cat-instagram-15s-subtitled.mp4
