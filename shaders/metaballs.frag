#include <flutter/runtime_effect.glsl>
#include "common/sizing.glsl"
#include "common/utils.glsl"

uniform sampler2D u_noiseTexture;

uniform vec4 u_colorBack;
uniform vec4 u_colors[8];
uniform float u_colorsCount;
uniform float u_size;
uniform float u_count;


out vec4 fragColor;

vec4 mb_colorAt(int index) {
  if (index <= 0) return u_colors[0];
  if (index == 1) return u_colors[1];
  if (index == 2) return u_colors[2];
  if (index == 3) return u_colors[3];
  if (index == 4) return u_colors[4];
  if (index == 5) return u_colors[5];
  if (index == 6) return u_colors[6];
  return u_colors[7];
}




  float randomR(vec2 p) {
    vec2 uv = floor(p) / 100. + .5;
    return texture(u_noiseTexture, fract(uv)).r;
  }

float noise(float x) {
  float i = floor(x);
  float f = fract(x);
  float u = f * f * (3.0 - 2.0 * f);
  vec2 p0 = vec2(i, 0.0);
  vec2 p1 = vec2(i + 1.0, 0.0);
  return mix(randomR(p0), randomR(p1), u);
}

float getBallShape(vec2 uv, vec2 c, float p) {
  float s = .5 * length(uv - c);
  s = 1. - clamp(s, 0., 1.);
  s = pow(s, p);
  return s;
}

float totalBallShapeAt(vec2 shapeUv, float t) {
  shapeUv += .5;
  float totalShape = 0.;

  for (int i = 0; i < 20; i++) {
    if (i >= int(ceil(u_count))) break;

    float idxFract = float(i) / float(20);
    float angle = TWO_PI * idxFract;

    float speed = 1. - .2 * idxFract;
    float noiseX = noise(angle * 10. + float(i) + t * speed);
    float noiseY = noise(angle * 20. + float(i) - t * speed);

    vec2 pos = vec2(.5) + 1e-4 + .9 * (vec2(noiseX, noiseY) - .5);

    float sizeFrac = 1.;
    if (float(i) > floor(u_count - 1.)) {
      sizeFrac *= fract(u_count);
    }

    float shape = getBallShape(shapeUv, pos, 45. - 30. * u_size * sizeFrac);
    shape *= pow(u_size, .2);
    shape = smoothstep(0., 1., shape);
    totalShape += shape;
  }

  return totalShape;
}

void main() {
  vec2 shape_uv = ps_objectUV();

  shape_uv += .5;

  const float firstFrameOffset = 2503.4;
  float t = .2 * (u_time + firstFrameOffset);

  vec3 totalColor = vec3(0.);
  float totalShape = 0.;
  float totalOpacity = 0.;

  for (int i = 0; i < 20; i++) {
    if (i >= int(ceil(u_count))) break;

    float idxFract = float(i) / float(20);
    float angle = TWO_PI * idxFract;

    float speed = 1. - .2 * idxFract;
    float noiseX = noise(angle * 10. + float(i) + t * speed);
    float noiseY = noise(angle * 20. + float(i) - t * speed);

    vec2 pos = vec2(.5) + 1e-4 + .9 * (vec2(noiseX, noiseY) - .5);

    int safeIndex = int(glsl_mod(float(i), max(u_colorsCount, 1.0)));
    vec4 ballColor = mb_colorAt(safeIndex);
    ballColor.rgb *= ballColor.a;

    float sizeFrac = 1.;
    if (float(i) > floor(u_count - 1.)) {
      sizeFrac *= fract(u_count);
    }

    float shape = getBallShape(shape_uv, pos, 45. - 30. * u_size * sizeFrac);
    shape *= pow(u_size, .2);
    shape = smoothstep(0., 1., shape);

    totalColor += ballColor.rgb * shape;
    totalShape += shape;
    totalOpacity += ballColor.a * shape;
  }

  totalColor /= max(totalShape, 1e-4);
  totalOpacity /= max(totalShape, 1e-4);

  float totalShapeX = totalBallShapeAt(ps_objectUV() + ps_objectPixelStepX(), t);
  float totalShapeY = totalBallShapeAt(ps_objectUV() + ps_objectPixelStepY(), t);
  float edge_width = max(ps_finiteFwidth(totalShape, totalShapeX, totalShapeY), ps_pixelDerivative(0.5));
  float finalShape = smoothstep(.4, .4 + edge_width, totalShape);

  vec3 color = totalColor * finalShape;
  float opacity = totalOpacity * finalShape;

  vec3 bgColor = u_colorBack.rgb * u_colorBack.a;
  color = color + bgColor * (1. - opacity);
  opacity = opacity + u_colorBack.a * (1. - opacity);

  
  color += 1. / 256. * (fract(sin(dot(.014 * vec2(FlutterFragCoord().x, u_resolution.y - FlutterFragCoord().y), vec2(12.9898, 78.233))) * 43758.5453123) - .5);


  fragColor = vec4(color, opacity);
}
