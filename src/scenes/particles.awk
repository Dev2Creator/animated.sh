BEGIN{
  W=int(w); H=int(h); T=t+0; srand(int(seed)+3); U=(uni==1); blank()
  if (mode=="ocean") ocean()
  else if (mode=="cosmos") cosmos()
  else if (mode=="garden") garden()
  else if (mode=="fireplace") fireplace()
  else if (mode=="matrix") matrix()
  else starfield()
  emit()
}
function ocean(  x,y,i,yy,c){
  c="\033[38;2;58;138;176m"
  for (y=0;y<H;y++){
    yy=int(2*sin((x_=y)/3.0 + T)*0)
    for (x=0;x<W;x++){
      if (y < int(H*0.25)) setc(x,y," ","")
      else if (y < int(H*0.55)) setc(x,y, (sin(x*0.3+T*2)>0.7?"~":" "), c)
      else setc(x,y, (sin(x*0.2-T*1.5+y*0.5)>0.2?"~":"_"), c)
    }
  }
  for (i=0;i<int(W/6)+4;i++){ x=int((i*37)%W); y=int((H-1) - ((T*6+i*5)%(H*0.7)))
    setc(x,y,(U?"○":"o"),"\033[38;2;180;220;240m") }
  for (i=0;i<3;i++){ x=int((T*4+i*40)%(W+10))-5; y=int(H*0.45+i*2)
    setc(x,y,(U?"▶":">"),"\033[38;2;120;170;200m"); setc(x-1,y,"<","\033[38;2;120;170;200m") }
  for (x=2;x<W;x+=7) setc(x,H-2,"}","\033[38;2;200;140;150m")
}
function cosmos(  i,x,y,b){
  for (i=0;i<int(W*H/45);i++){ x=ri(0,W-1); y=ri(0,H-1); b=sin(T*1.4+i)
    setc(x,y,(b>0.7?"*":(b>0?".":"+")),(b>0.7?"\033[38;2;255;250;230m":"\033[38;2;150;150;190m")) }
  setc(int(W*0.7),int(H*0.3),(U?"●":"O"),"\033[38;2;230;180;150m")
  setc(int(W*0.3),int(H*0.6),(U?"○":"o"),"\033[38;2;170;200;230m")
  i=int((T*3)%(W+20)); setc(i-10,int(H*0.2),"-","\033[38;2;240;240;255m")
  for (x=0;x<W;x+=4) setc((x+int(T))%W, int(H*0.8)+int(sin(x+T)*2), ".", "\033[38;2;120;110;160m")
}
function garden(  x,y,i){
  for (x=0;x<W;x++) setc(x,H-2,"_","\033[38;2;150;150;140m")
  i=int(T*2)%6
  for (y=0;y<H/2;y++) for (x=0;x<W;x++){
    if (int(sin((x-40)/6+T)*3+y)==0) setc(x,y,"~","\033[38;2;170;190;200m") }
  for (i=0;i<4;i++) setc(10+i*17, H-3, (U?"●":"o"), "\033[38;2;120;120;120m")
  for (i=0;i<int(W/12);i++){ x=int((ri(0,W-1)+int(T*2))%W); y=int((T*4+i*9)%H)
    setc(x,y,"*","\033[38;2;240;190;210m") }
}
function fireplace(  x,y,h1,i){
  for (x=0;x<W;x+=1){
    h1=int(3+2*sin(x*0.4+T*3)+2*sin(x*0.9-T*2))
    for (y=0;y<h1;y++){
      setc(x, H-2-y, (y<h1-1 ? (rand()<0.5?"^":"~") : "*"), "\033[38;2;240;" (120-int(y*12)) ";" (60+int(y*20)) "m")
    }
  }
  for (x=0;x<W;x+=2) setc(x,H-1,"=","\033[38;2;120;90;70m")
  for (i=0;i<int(W/10);i++) setc(int((ri(0,W-1)+sin(T+i)*2+W)%W), int((H-3)-((T*5+i*7)%(H-4))), ".", "\033[38;2;250;200;120m")
}
function matrix(  i,x,y,glyph){
  for (i=0;i<int(W/2);i++){
    x=(i*2+1)%W
    y=(i*3 + int(T*(4+i%5)))%H
    glyph=substr("01abcdef#*+", 1+int(rand()*11), 1)
    setc(x,y,glyph,"\033[38;2;190;240;200m")
    setc(x,(y-1+H)%H,glyph,"\033[38;2;60;140;90m")
    setc(x,(y-2+H)%H,glyph,"\033[38;2;40;100;70m")
  }
}
function starfield(  i,x,y,z){
  for (i=0;i<int(W*H/60)+10;i++){
    z=1+ (i%5); x=int((ri(0,W-1)+T*(1+z))%W); y=ri(0,H-1)
    setc(x,y,(z>3?"*":(z>2?"+":".")),(z>3?"\033[38;2;240;240;255m":(z>2?"\033[38;2;200;200;230m":"\033[38;2;150;150;180m")))
  }
}
