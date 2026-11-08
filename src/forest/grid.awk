# grid.awk - shared grid helpers, sourced by scene awk programs
function setc(x,y,c,colour){ x=int(x); y=int(y); if (x<0||x>=W||y<0||y>=H) return
  if (ch[y,x]==" " || c!=" "){ ch[y,x]=c; fg[y,x]=colour } }
function clr(x,y){ x=int(x); y=int(y); if (x<0||x>=W||y<0||y>=H) return; ch[y,x]=" "; fg[y,x]="" }
function ri(a,b){ return a+int(rand()*(b-a+1)) }
function absv(v){ return v<0?-v:v }
function emit(  x,y,last,out){
  printf "\033[H"
  for (y=0;y<H;y++){
    last=""
    for (x=0;x<W;x++){
      if (fg[y,x]!=last){ printf "%s", fg[y,x]; last=fg[y,x] }
      printf "%s", ch[y,x]
    }
    printf "\033[0m\033[K\n"
  }
}
function blank(){ for (y=0;y<H;y++) for (x=0;x<W;x++){ ch[y,x]=" "; fg[y,x]="" } }
BEGIN{ if (W=="") W=80; if (H=="") H=24 }
