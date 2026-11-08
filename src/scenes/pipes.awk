BEGIN{
  W=int(w); H=int(h); T=t+0; seed=int(seed); U=(uni==1); blank()
  srand(seed+9)
  for (i=0;i<n;i++) pipe(i)
  emit()
}
function glyph(style, dir,  s){
  if (style=="classic"){ s=(U?"│":"|") }
  if (style=="classic"){ if (dir=="h") s=(U?"─":"-"); else s=(U?"│":"|") }
  if (style=="neon"){ if (dir=="h") s=(U?"═":"="); else s=(U?"║":"|") }
  if (style=="garden"){ s=(dir=="h"?(U?"╰":"~"):(U?"│":"|")) }
  return s
}
function pcol(style, idx,  c){
  if (style=="neon") c="\033[38;2;120;240;200m"
  else if (style=="garden") c="\033[38;2;126;180;120m"
  else if (style=="rainbow") c="\033[38;2;220;150;200m"
  else c="\033[38;2;170;190;220m"
  return c
}
function pipe(idx,  x,y,len,dir,ch,steps,k,c){
  srand(seed + idx*17)
  x=int(rand()*W); y=int(rand()*H); len=int(4+rand()*12)
  dir=int(rand()*4); c=pcol(style, idx)
  for (k=0;k<len*6;k++){
    ch=glyph(style, (dir%2==0?"h":"v"))
    setc(x,y,ch,c)
    if (k%int(3+idx%4)==0) dir=(dir + (rand()<0.5?1:3))%4
    if (dir==0) x++; else if (dir==1) y++; else if (dir==2) x--; else y--
    if (x<0||x>=W||y<0||y>=H){ x=int(rand()*W); y=int(rand()*H) }
  }
}
