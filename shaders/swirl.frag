#include <flutter/runtime_effect.glsl>
#include "common/sizing.glsl"
#include "common/utils.glsl"

uniform vec4 u_colorBack;
uniform vec4 u_colors[10];
uniform float u_colorsCount;
uniform float u_bandCount;
uniform float u_twist;
uniform float u_center;
uniform float u_proportion;
uniform float u_softness;
uniform float u_noise;
uniform float u_noiseFrequency;


out vec4 fragColor;

vec4 sw_colorAt(int index) {
  if (index <= 0) return u_colors[0];
  if (index == 1) return u_colors[1];
  if (index == 2) return u_colors[2];
  if (index == 3) return u_colors[3];
  if (index == 4) return u_colors[4];
  if (index == 5) return u_colors[5];
  if (index == 6) return u_colors[6];
  if (index == 7) return u_colors[7];
  if (index == 8) return u_colors[8];
  return u_colors[9];
}





vec2 rotate(vec2 uv, float th) {
  return mat2(cos(th), sin(th), -sin(th), cos(th)) * uv;
}

vec3 swirlFieldAt(vec2 shapeUv, float t) {
  float l = max(1e-4, length(shapeUv));
  float angle = ceil(u_bandCount) * atan(shapeUv.y, shapeUv.x) + t;
  float angle_norm = angle / TWO_PI;

  float twist = 3. * clamp(u_twist, 0., 1.);
  float offset = pow(l, -twist) + angle_norm;

  float shape = fract(offset);
  shape = 1. - abs(2. * shape - 1.);
  shape += u_noise * snoise(15. * pow(u_noiseFrequency, 2.) * shapeUv);

  float mid = smoothstep(.2, .2 + .8 * u_center, pow(l, twist));
  shape = mix(0., shape, mid);

  float proportion = clamp(u_proportion, 0., 1.);
  float exponent = mix(.25, 1., proportion * 2.);
  exponent = mix(exponent, 10., max(0., proportion * 2. - 1.));
  shape = pow(shape, exponent);

  return vec3(shape, l, twist);
}


void main() {
  vec2 shape_uv = ps_objectUV();

  float t = u_time;
  vec3 field = swirlFieldAt(shape_uv, t);
  vec3 fieldX = swirlFieldAt(shape_uv + ps_objectPixelStepX(), t);
  vec3 fieldY = swirlFieldAt(shape_uv + ps_objectPixelStepY(), t);
  float shape = field.x;
  float l = field.y;
  float twist = field.z;
  float shapeFwidth = max(ps_finiteFwidth(shape, fieldX.x, fieldY.x), ps_pixelDerivative(0.5));

  float mixer = shape * u_colorsCount;
  vec4 gradient = sw_colorAt(0);
  gradient.rgb *= gradient.a;

  float outerShape = 0.;
  for (int i = 1; i < 11; i++) {
    if (i > int(u_colorsCount)) break;

    float m = clamp(mixer - float(i - 1), 0., 1.);
    float aa = u_colorsCount * shapeFwidth;
    m = smoothstep(.5 - .5 * u_softness - aa, .5 + .5 * u_softness + aa, m);

    if (i == 1) {
      outerShape = m;
    }

    vec4 c = sw_colorAt(i - 1);
    c.rgb *= c.a;
    gradient = mix(gradient, c, m);
  }

  float midValue = pow(l, -twist);
  float midValueX = pow(fieldX.y, -twist);
  float midValueY = pow(fieldY.y, -twist);
  float midAA = .1 * max(ps_finiteFwidth(midValue, midValueX, midValueY), ps_pixelDerivative(0.5));
  float outerMid = smoothstep(.2, .2 + midAA, pow(l, twist));
  outerShape = mix(0., outerShape, outerMid);

  vec3 color = gradient.rgb * outerShape;
  float opacity = gradient.a * outerShape;

  vec3 bgColor = u_colorBack.rgb * u_colorBack.a;
  color = color + bgColor * (1.0 - opacity);
  opacity = opacity + u_colorBack.a * (1.0 - opacity);

  
  color += 1. / 256. * (fract(sin(dot(.014 * vec2(FlutterFragCoord().x, u_resolution.y - FlutterFragCoord().y), vec2(12.9898, 78.233))) * 43758.5453123) - .5);


  fragColor = vec4(color, opacity);
}
