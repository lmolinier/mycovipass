
```
convert '*.png[!115x115^]' -background transparent -gravity south -extent 128x128 work/converted.png
montage 'converted*.png' -background transparent -mode concatenate -gravity
center -tile 8x output.png
```