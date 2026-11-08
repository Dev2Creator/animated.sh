BEGIN{
  W=int(w); H=int(h); T=t+0; srand(int(seed)+1); U=(uni==1)
  blank()
  skycol(time, season)
  draw_stars(); draw_sunmoon(); draw_clouds(); draw_mountains()
  treeline(int(H*0.64), 0.55, 6, 20, 1)
  treeline(int(H*0.80), 0.8, 9, 34, 2)
  draw_ground(); draw_weather(); emit()
}
function skycol(tm,sea,  c){
  if (tm=="night") c="\033[48;2;14;16;30m"
  else if (tm=="evening") c="\033[48;2;44;30;48m"
  else if (sea=="winter") c="\033[48;2;236;242;248m"
  else if (tm=="morning") c="\033[48;2;252;240;236m"
  else c="\033[48;2;238;246;238m"
  printf "%s", c; BG=c
}
function draw_stars(  i,x,y,b){
  if (time!="night" && time!="evening") return
  for (i=0;i<int(W*H/70)+8;i++){
    x=ri(0,W-1); y=ri(0,int(H*0.5)); b=sin(T*0.8+i)
    setc(x,y, (b>0.6?"*":(b>-0.3?".":" ")), (b>0.6?"\033[38;2;255;250;220m":"\033[38;2;120;120;150m"))
  }
}
function draw_sunmoon(  cx,cy){
  if (time=="night"){ cx=int(W*0.8); cy=2; setc(cx,cy,(U?"◐":"o"),"\033[38;2;238;238;210m") }
  else if (time=="evening"){ cx=int(W*0.18); cy=int(H*0.45); setc(cx,cy,(U?"◯":"O"),"\033[38;2;250;170;120m") }
  else { cx=int(W*0.85); cy=2; setc(cx,cy,(U?"☀":"O"),"\033[38;2;255;226;150m") }
}
function draw_clouds(  i,cx,cy,j,w1){
  for (i=0;i<3;i++){
    cx=int((T*(3+i)+i*W/3) % (W+16))-8; cy=2+i*2; w1=6+i*3
    for (j=0;j<w1;j++) setc(cx+j,cy,(j==0||j==w1-1?"(":"~"),"\033[38;2;206;206;222m")
    setc(cx+1,cy-1,".","\033[38;2;206;206;222m")
  }
}
function draw_mountains(  i,pk,hgt,x,base){
  base=int(H*0.60)
  for (i=0;i<3;i++){
    pk=int(W*(0.15+0.33*i)); hgt=int(H*(0.15+0.05*i))
    for (x=0;x<W;x++){
      if (absv(x-pk)<hgt*2.6){
        if (x==pk) setc(x,base-hgt,(U?"▲":"^"),"\033[38;2;150;150;170m")
        else if (absv(x-pk)<hgt) setc(x,base-int(hgt-absv(x-pk)/2),(x<pk?"/":"\\"),"\033[38;2;150;150;170m")
        else if (absv(x-pk)<hgt*2) setc(x,base-int(hgt/2),".","\033[38;2;150;150;170m")
      }
    }
  }
}
function leafcol(season,  c){
  if (season=="autumn") c="\033[38;2;196;120;74m"
  else if (season=="winter") c="\033[38;2;210;220;228m"
  else if (season=="summer") c="\033[38;2;74;130;92m"
  else c="\033[38;2;146;186;150m"
  return c
}
function canopychar(season, type,  c){
  if (season=="winter") c=(rand()<0.5?"*":".")
  else if (season=="autumn") c=(rand()<0.4?"o":(rand()<0.5?"#":"*"))
  else if (type=="blossom") c=(rand()<0.4?"*":"o")
  else c=(rand()<0.35?"@":(rand()<0.5?"#":"%"))
  return c
}
function tree(x, base, hgt, type, season,  i,j,sway,col,top,y){
  col=leafcol(season)
  sway=int(sin(T*1.1 + x*0.25)*1.4)
  top=base-hgt
  if (type=="dead"){
    for (i=0;i<hgt;i++) setc(x, base-i, "|", "\033[38;2;120;104;96m")
    for (i=2;i<hgt;i+=3){ setc(x-1, base-i, "/", "\033[38;2;120;104;96m"); setc(x+1, base-i, "\\", "\033[38;2;120;104;96m") }
    return
  }
  if (type=="pine"){
    for (i=0;i<hgt;i++){
      setc(x, base-i, "|", "\033[38;2;110;94;86m")
      if (i%2==0) { setc(x-1, base-i, "/", col); setc(x+1, base-i, "\\", col) }
      if (i%3==0) { setc(x-2, base-i, "/", col); setc(x+2, base-i, "\\", col) }
    }
    setc(x+sway, top-1, (U?"▲":"^"), col)
    return
  }
  if (type=="birch"){
    for (i=0;i<hgt;i++) setc(x, base-i, "|", "\033[38;2;236;232;224m")
    j=int(hgt*0.25)
  } else if (type=="willow"){
    for (i=0;i<hgt;i++) setc(x, base-i, "|", "\033[38;2;112;96;86m")
    for (i=1;i<hgt;i+=2) for (j=1;j<=3;j++){ setc(x+j+sway, base-i, "/", col); setc(x-j+sway, base-i, "\\", col) }
    return
  } else {
    for (i=0;i<hgt;i++) setc(x, base-i, "|", "\033[38;2;112;96;86m")
    j=int(hgt*0.3)
  }
  for (i=0;i<=j;i++) for (y=-i;y<=i;y++){
    if ((i+y)%2==0 || i==j) setc(x+y+sway, top+i, canopychar(season,type), col)
  }
  for (i=1;i<j/2;i++) for (y=-i;y<=i;y++) setc(x+y+sway, top+i, canopychar(season,type), col)
}
function treeline(basey, dens, minh, maxh, layer,  n,i,x,hgt,type,r){
  n=int(W*dens/9)+2
  for (i=0;i<n;i++){
    x=ri(0,W-1)
    hgt=ri(minh,maxh)
    r=rand()
    if (season=="spring" && r<0.3) type="blossom"
    else if (r<0.2) type="pine"
    else if (r<0.32) type="birch"
    else if (r<0.42) type="willow"
    else if (r<0.5 && season=="autumn") type="dead"
    else type="oak"
    if (layer==1) { hgt=int(hgt*0.6); }
    tree(x, basey, hgt, type, season)
  }
}
function draw_ground(  x,i,blade,col){
  col="\033[38;2;126;164;118m"
  for (x=0;x<W;x++){
    if (rand()<0.55) setc(x,H-1,"_","\033[38;2;120;112;96m")
    if (rand()<0.5) setc(x,H-2, (sin(T*2+x*0.4)>0?"'":"`"), col)
    if (rand()<0.22) setc(x,H-3, "|", col)
    if (rand()<0.05){ blade=(rand()<0.5?"*":"o"); setc(x,H-3,(season=="winter"?".":blade),"\033[38;2;214;150;180m") }
    if (rand()<0.03) setc(x,H-4,(U?"♥":"v"),"\033[38;2;200;120;140m")
    if (rand()<0.02) setc(x,H-5,"o","\033[38;2;230;210;180m")
  }
  if (season=="winter") for (x=0;x<W;x+=2) setc(x,H-2,".","\033[38;2;230;238;244m")
}
function draw_weather(  i,x,y,n,col,dx,dy){
  if (weather=="rain" || weather=="storm"){
    n=int(W*(weather=="storm"?0.5:0.22)); col="\033[38;2;150;170;200m"
    for (i=0;i<n;i++){
      x=ri(0,W-1); y=(ri(0,H-1)+int(T*22))%H
      setc(x,y,(U?"│":"|"),col); setc(x-1,y-1,(U?"╱":"/"),col)
    }
  }
  if (weather=="snow"){
    n=int(W*0.35); col="\033[38;2;245;250;255m"
    for (i=0;i<n;i++){
      x=ri(0,W-1); y=(ri(0,H-1)+int(T*7))%H; dx=int(sin(T*1.5+i)*2)
      setc(x+dx,y,(rand()<0.5?"*":"."),col)
    }
  }
  if (weather=="fog"){
    for (y=int(H*0.45); y<H; y+=2){ for (x=0;x<W;x++){ if (rand()<0.30-int(T)%1) setc(x,y,".", "\033[38;2;200;200;210m") } }
    for (x=0;x<W;x+=3) setc((x+int(T*3))%W, int(H*0.6)+ri(0,3), "~", "\033[38;2;210;210;220m")
  }
  if (weather=="storm" && int(T*10)%37==0){
    for (y=0;y<H;y++) for (x=0;x<W;x++) fg[y,x]="\033[48;2;250;250;255m"
  }
  if (weather!="rain" && weather!="storm" && time!="night" && rand()<0.9) draw_birds()
  if (time=="night") draw_fireflies()
  if (season=="spring"||season=="autumn") draw_petals()
}
function draw_birds(  i,x,y){
  for (i=0;i<2;i++){ x=int((T*6+i*30)%(W+10))-5; y=3+i*2
    setc(x,y,"v","\033[38;2;90;90;100m"); setc(x+1,y,"^","\033[38;2;90;90;100m") }
}
function draw_fireflies(  i,x,y){
  if (fireflies=="0") return
  for (i=0;i<int(W/8);i++){ x=int((ri(0,W-1)+sin(T*1.2+i)*3+W)%W); y=int(H*0.55+ri(0,int(H*0.4)))
    if (sin(T*3+i)>0) setc(x,y,"*","\033[38;2;240;236;140m") }
}
function draw_petals(  i,x,y){
  for (i=0;i<int(W/10);i++){ x=int((ri(0,W-1)+int(T*4)+i*7)%W); y=(ri(0,H-6)+int(T*3))%int(H*0.8)
    setc(x,y,(season=="autumn"?"o":"*"),(season=="autumn"?"\033[38;2;200;130;80m":"\033[38;2;240;180;200m")) }
}
