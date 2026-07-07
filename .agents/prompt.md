new plans...
1.
-  add exclusive?(bool), [margin,padding].[top,bottom,left,right,horizontal,vertical,all] (int), transparency:[clear,blur]  prop to all containers e.g.  windows, panels, bars, boxes etc.. 
e.g.
```yaml
exclusive: true
transparency: blur
margin:
 top: 4
 horizontal: 5

padding:
 all: 8
```

- make the anchor a parent type... like the config should be
```yaml
anchor:
 - top
 - bottom
 - left
```
will create a panel that expands top to bottom, and calculates the width from left..
all the available options should be [top,bottom,left,right,center]

2. currently, the config.yaml doesnt work properly for terms like `label: "\u{2715}"`... like it doesnt render the icon, instead, just shows `\u{2715}`... so fix the yaml parser for that support

3. make a popup widget... (inherit the container type i explained)
- sits above all elem (highest GTK layer)
- has `size`:[auto(fit content) || {X:int,Y:int} || fill]
- all props from container type (except excluisive..)
- covers the screen with a black fade... configurable in yaml as:
```yaml
nebula/popup:
  - overlay: 
    enabled: true
    intensity : 4
  - size: 400X300
  - size: auto
  - size: fill
```  

