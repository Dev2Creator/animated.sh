BEGIN{
  W=int(w); H=int(h); T=t+0; srand(int(seed)+5); U=(uni==1); blank()
  N=length(msg); if (N<1) msg="animated.sh"
  if (effect=="") effect="typewriter"
  cx=int(W/2 - N/2); cy=int(H/2)
  if (effect=="typewriter"||effect=="reveal") do_type()
  else if (effect=="rainbow") do_rainbow()
  else if (effect=="gradient") do_gradient()
  else if (effect=="wave") do_wave(0)
  else if (effect=="bounce") do_wave(1)
  else if (effect=="marquee") do_marquee()
  else if (effect=="slide") do_slide()
  else if (effect=="scramble") do_scramble()
  else if (effect=="fade") do_gradient()
  else if (effect=="pulse") do_pulse()
  else if (effect=="glow") do_glow()
  else if (effect=="rotate") do_rotate()
  else if (effect=="scroll") do_scroll()
  else if (effect=="matrix") do_matrix()
  else if (effect=="star") do_star()
  else if (effect=="fire") do_fire()
  else if (effect=="particle") do_particle()
  else if (effect=="spiral") do_spiral()
  else do_type()
  emit()
}
function put(x,y,c,col){ setc(x,y,c,col) }
function color(r,g,b){ return sprintf("\033[38;2;%d;%d;%dm", int(r), int(g), int(b)) }
function do_type(  i,shown,c){
  shown=int(T*12); if (shown>N) shown=N
  for (i=0;i<shown;i++) put(cx+i, cy, substr(msg,i+1,1), color(210,160,190))
  if (int(T*4)%2==0) put(cx+shown, cy, "_", color(200,140,170))
}
function do_rainbow(  i){ for (i=0;i<N;i++) put(cx+i, cy, substr(msg,i+1,1), color(200+40*sin(i+T), 140+80*sin(i*0.7+T*1.3), 170+60*sin(i*0.4-T))) }
function do_gradient(  i,f){ for (i=0;i<N;i++){ f=(N>1? i/(N-1):0); put(cx+i, cy, substr(msg,i+1,1), color(240-60*f, 150+40*f, 200-40*f)) } }
function do_wave(bounce,  i,dy){ for (i=0;i<N;i++){ dy=int(2*sin(T*3 + i*0.5)); if (bounce) dy=int(2.5*absv(sin(T*3 + i*0.5))); put(cx+i, cy+dy, substr(msg,i+1,1), color(200,160,210)) } }
function do_marquee(  i,off){ off=int(T*10)%(N+W); for (i=0;i<N;i++) put((i+W-off), cy, substr(msg,i+1,1), color(210,170,190)) }
function do_slide(  i,off){ off=int(10*sin(T)); for (i=0;i<N;i++) put(cx+i+off, cy, substr(msg,i+1,1), color(180,200,220)) }
function do_scramble(  i,c,shown){ shown=int(T*8)
  for (i=0;i<N;i++){ if (i<shown) c=substr(msg,i+1,1); else c=substr("!<>-_\\/[]{}=+*^?#", 1+int(rand()*20), 1)
    put(cx+i, cy, (c==" "?" ":c), color(i<shown?230:120, i<shown?180:120, i<shown?200:140)) } }
function do_pulse(  i,b){ b=int(60+60*absv(sin(T*2))); for (i=0;i<N;i++) put(cx+i, cy, substr(msg,i+1,1), color(190+b/3, 120+b/3, 170+b/4)) }
function do_glow(  i){ for (i=0;i<N;i++) put(cx+i, cy, substr(msg,i+1,1), color(255,230,240)) }
function do_rotate(  i,step){ step=int(T*2)%8; for (i=0;i<N;i++) put(cx+ (i%2), cy - N/2 + i, substr(msg,i+1,1), color(200,170,200)) }
function do_scroll(  i,y0){ y0=int((T*4)%(H+N)); for (i=0;i<N;i++) put(cx+i, y0-i, substr(msg,i+1,1), color(190,190,220)) }
function do_matrix(  i,y){ for (i=0;i<N;i++){ y=int((T*6+i*2)%H); put(cx+i, y, substr(msg,i+1,1), color(150,240,180)); put(cx+i,(y-1+H)%H,substr(msg,i+1,1),color(70,150,100)) } }
function do_star(  i){ for (i=0;i<N;i++){ put(cx+i, cy, substr(msg,i+1,1), color(255,240,220))
    if (sin(T*4+i)>0.6) put(cx+i-1, cy-1, "*", color(255,220,180)) } }
function do_fire(  i,y){ for (i=0;i<N;i++){ y=cy+int(sin(T*5+i)*1.2); put(cx+i, y, substr(msg,i+1,1), color(250,160+int(40*sin(T*3+i)),90)) } }
function do_particle(  i,px,py,d){ for (i=0;i<N;i++){ d=((T*6+i)%14); px=cx+i; py=cy-d; put(px,py,substr(msg,i+1,1),(d<2?color(240,220,240):color(140,120,160))) } }
function do_spiral(  i,a,r){ for (i=0;i<N;i++){ a=T*2 + i*0.6; r=3+i*0.32; put(cx+int(r*cos(a)), cy+int(r*sin(a)*0.6), substr(msg,i+1,1), color(200,170,220)) } }
