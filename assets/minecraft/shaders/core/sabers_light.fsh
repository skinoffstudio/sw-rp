#version 150
#moj_import <fog.glsl>
uniform sampler2D Sampler0;


uniform vec4 ColorModulator;


uniform float FogStart;


uniform float FogEnd;


uniform vec4 FogColor;


uniform float GameTime;


in float vertexDistance;


in vec4 vertexColor;


in vec4 overlayColor;


in vec2 texCoord0;


in vec4 shadeColor;


in vec4 lightMapColor;


flat in float finish;


out vec4 fragColor;


vec2 rotate(vec2 v,float a){float s=sin(a);


float c=cos(a);


mat2 m=mat2(c,-s,s,c);


return m*v;


}float noise21(vec2 p){return fract(sin(dot(p,vec2(12.9898,4.1414)))*43758.547);


}vec2 noise22(vec2 p){return fract(vec2(noise21(p),noise21(p+232.245)));


}vec3 noise23(vec2 p){return fract(vec3(noise21(p),noise21(p+232.245),noise21(p+345.768)));


}vec4 molten(vec2 p){vec4 col=vec4(1.,0.,0.,0.);


float column=floor(p.x/3.);


float part=mod(p.x,3.);


float t=noise21(vec2(column*63.,0.));


float where=mod(floor(GameTime*(8000.+floor(t*8000.)))-floor(t*24.+abs(part-1.))-p.y,20.);


if(where<10.&&part<3.){float b=1.-where/10.;


col.a+=b;


if(b>0.5)col.g+=0.3;


if(b>0.9)col.rgb+=vec3(0.25);


}return col;


}vec3 matrix(vec2 uv,vec3 shade,vec2 dim){vec2 uv2=mod(uv,8.)/8.;


vec2 block=uv/8.-uv2;


uv2.x+=floor(noise21(block+floor(GameTime*(5000.+200.*floor(8.*noise21(block+1.31)))))*10.);


vec4 letter=texture(Sampler0,(uv2*8.+vec2(0.,497.))/dim);


vec3 col=shade*letter.rgb*letter.a;


uv.x-=mod(uv.x,8.);


float offset=sin(uv.x*15.);


float speed=cos(uv.x*3.)*0.3+0.7;


float y=1.-fract(floor(uv.y/2.)/16.-GameTime*1000.*speed+offset);


col*=shade/(y*20.);


return col;


}vec4 flowers(vec2 uv,float size,float s,vec2 dim,vec2 tex){uv/=size;


uv*=s;


float column=floor(uv.x/s);


float tx=fract(uv.x/s)*size;


vec2 n=noise22(vec2(column,column*2.3));


float time=GameTime*(500.+floor(n.x*8.)*250.);


float ct=uv.y-time+n.y*size;


float t=mod(ct,size);


float ty=t*(size/s);


vec2 rot=rotate(vec2(tx,ty)-size/2.,(n.x<0.5?-1.:1.)*GameTime*1000.+column)+size/2.;


if(rot.y>=0.&&rot.y<size&&rot.x>=0.&&rot.x<size){float shadei=min(mod(floor(n.y*7.)+floor(ct/size),7.),6.);


vec3 shade0=texture(Sampler0,vec2(0.,304.+shadei)/dim).rgb;


vec3 shade1=texture(Sampler0,vec2(1.,304.+shadei)/dim).rgb;


vec4 c0=texture(Sampler0,(rot+tex)/dim);


vec4 c1=texture(Sampler0,(rot+tex+vec2(16.,0.))/dim);


vec3 v=mix(mix(shade1,shade0,c0.r),c1.rgb,c1.a);


return vec4(v,min(c0.a+c1.a,1.));


}return vec4(0.);


}void main(){vec4 rgb=texture(Sampler0,texCoord0);


vec4 vCol=vertexColor;


vec4 sCol=shadeColor;


if(vCol==vec4(0.)&&rgb.xw==vec2(1.)){vCol=vec4(1.);


sCol=vec4(1.);


if(shadeColor.x>1.)rgb=vec4(0.);


else if(rgb.y<shadeColor.x){float t=2.*shadeColor.x;


rgb=vec4(vec3(t<1.?1.:2.-t,t<1.?t:1.,0.),1.);


}else rgb=vec4(vec3(0.),1.);


}float rr=sign(abs(rgb.a-240./255.));


float e=sign(abs(rgb.a-254./255.))*rr;


float noshade=sign(abs(rgb.a-253./255.));


rgb.a=mix(mix(0.75,1.,rr),rgb.a,e*noshade);


if(finish>0.){vec2 dim=vec2(textureSize(Sampler0,0));


vec2 uv=texCoord0*dim;


if(finish==1.){float t=GameTime*1000.;


float t2=fract(t);


float x01=mod(floor(t),8.)*16.;


float x1=mod(floor(t)+1,8.)*16.;


vec4 overlay1=texture(Sampler0,(mod(uv,16.)+vec2(x01,256.))/dim);


vec4 overlay2=texture(Sampler0,(mod(uv,16.)+vec2(x1,256.))/dim);


vec4 overlay=mix(overlay1,overlay2,t2);


rgb.rgb*=overlay.rgb;


}else if(finish==2.){float per=12000.;


float x0=mod(floor(GameTime*per),30.)*16.;


vec4 overlay11=texture(Sampler0,(mod(uv,16.)+vec2(x0+16.,272.))/dim);


rgb.rgb=texture(Sampler0,vec2(0.,272.+round(0.8*rgb.x*9.+0.25)+round(overlay11.a))/dim).rgb;


}else if(finish==3.){vec2 p2=uv*1.5;


p2=rotate(p2,0.15);


float t=GameTime*4000.;


rgb.rgb*=texture(Sampler0,(mod(uv-t,16.)+vec2(0.,288.))/dim).rgb+0.5*texture(Sampler0,(mod(p2-t,16.)+vec2(0.,288.))/dim).rgb;


}else if(finish==4.){vec3 col=vec3(0.25,0.025,0.025)*3.;


vec4 s1=molten(floor(mod(uv,128.)));


vec4 s2=molten(floor(mod(uv*2.+vec2(722.,63.),128.)));


vec3 rgbsum=floor((s1.rgb+s2.rgb)*4.+0.5)/4.;


col=mix(col,rgbsum,s1.a+s2.a*0.4);


rgb.rgb*=col;


}else if(finish==5.){vec2 p2=uv*1.5;


p2=rotate(p2,0.15);


vec2 bob=vec2(sin(GameTime*4000.)*0.75,0.);


vec2 bob1=vec2(sin(GameTime*4000.-1500.)*0.75,0.);


rgb.rgb*=texture(Sampler0,(mod(uv,16.)+vec2(16.,288.))/dim).rgb+texture(Sampler0,(mod(uv*1.75-bob+vec2(0.,GameTime*6000.),16.)+vec2(32.,288.))/dim).rgb+texture(Sampler0,(mod(uv*1.75-bob1+vec2(0.,GameTime*6000.+3000.),16.)+vec2(32.,288.))/dim).rgb+texture(Sampler0,(mod(uv*1.25-bob+vec2(0.,GameTime*6000.),16.)+vec2(64.,288.))/dim).rgb+texture(Sampler0,(mod(uv*1.25-bob+vec2(12.,GameTime*3000.+3000.),16.)+vec2(64.,288.))/dim).rgb+texture(Sampler0,(mod(uv*1.-bob1+vec2(0.,GameTime*8000.),16.)+vec2(48.,288.))/dim).rgb;


}else if(finish==6.){float t=GameTime*100.+(uv.x+uv.y)/32.;


float pct=sin(fract(t)*(3.141593/2.));


pct*=pct;


float x0=mod(floor(t),4.)*16.;


float x1=mod(floor(t)+1,4.)*16.;


vec3 col0=texture(Sampler0,(mod(uv,16.)+vec2(48+x0,304.))/dim).rgb;


vec3 col1=texture(Sampler0,(mod(uv,16.)+vec2(48+x1,304.))/dim).rgb;


vec3 col=mix(col0,col1,pct);


vec4 f=flowers(uv,3.,1.,dim,vec2(22.,314.));


col=mix(col,f.rgb,f.a*0.75);


f=flowers(uv,6.,1.,dim,vec2(16.,314.));


col=mix(col,f.rgb,f.a*0.8);


f=flowers(uv,10.,1.,dim,vec2(16.,304.));


col=mix(col,f.rgb,f.a);


rgb.rgb*=col;


}else if(finish==7.){vec3 shade=vec3(0.,1.,0.3);


vec3 col=matrix(uv,shade,dim)*0.7+min(matrix(uv*3.-2.,shade,dim)*0.5,0.25);


rgb.rgb*=shade*0.1*0.95+0.05;


rgb.rgb+=col.rgb;


}}if(rgb==vec4(0.,1.,1.,1.))fragColor=vec4(0.);


else{vec4 color=rgb*mix(sCol,vCol,e*noshade)*ColorModulator;


if(color.a<0.1)discard;


color.rgb=mix(overlayColor.rgb,color.rgb,overlayColor.a);


color*=mix(vec4(1.),lightMapColor,e);


fragColor=linear_fog(color,vertexDistance-(1.-e)*4.,FogStart,FogEnd,FogColor);


}}