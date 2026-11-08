BEGIN{
  W=int(w); H=int(h); T=t+0; blank()
  split("0123456789:", d, "")
  F["0"]="111101101101111"; F["1"]="010110010010111"; F["2"]="111001111100111"
  F["3"]="111001111001111"; F["4"]="101101111001001"; F["5"]="111100111001111"
  F["6"]="111100111101111"; F["7"]="111001001001001"; F["8"]="111101111101111"
  F["9"]="111101111001111"; F[":"]="000010000010000"
  label=clocktext
  cw=3; gap=1; total=length(label)*(cw+gap)
  x0=int((W-total)/2); y0=int((H-5)/2)
  col="\033[38;2;220;160;190m"
  for (i=1;i<=length(label);i++){
    c=substr(label,i,1); pat=F[c]; if (pat=="") continue
    for (r=0;r<5;r++) for (k=0;k<3;k++) if (substr(pat, r*3+k+1,1)=="1")
      setc(x0+(i-1)*(cw+gap)+k, y0+r, block, col)
  }
  if (showdate=="1") for (i=1;i<=length(datetext);i++) setc(int((W-length(datetext))/2)+i-1, y0+7, substr(datetext,i,1), "\033[38;2;170;160;190m")
  emit()
}
