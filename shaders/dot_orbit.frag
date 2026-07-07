#include <flutter/runtime_effect.glsl>
#include "common/sizing.glsl"
#include "common/utils.glsl"

uniform sampler2D u_noiseTexture;
uniform vec4 u_colorBack;
uniform vec4 u_colors[10];
uniform float u_colorsCount;
uniform float u_stepsPerColor;
uniform float u_size;
uniform float u_sizeRange;
uniform float u_spreading;

out vec4 fragColor;

vec4 do_colorAt(int index) {
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

vec2 do_rotate(vec2 uv, float th) {
  return mat2(cos(th), sin(th), -sin(th), cos(th)) * uv;
}

float do_randomR(vec2 p) {
  vec2 uv = floor(p) / 100.0 + 0.5;
  return texture(u_noiseTexture, fract(uv)).r;
}

vec2 do_randomGB(vec2 p) {
  vec2 uv = floor(p) / 100.0 + 0.5;
  return texture(u_noiseTexture, fract(uv)).gb;
}

vec3 do_voronoiShape(vec2 uv, float time) {
  vec2 i_uv = floor(uv);
  vec2 f_uv = fract(uv);

  float spreading = 0.25 * clamp(u_spreading, 0.0, 1.0);

  float minDist = 1.0;
  vec2 randomizer = vec2(0.0);
  for (int y = -1; y <= 1; y++) {
    for (int x = -1; x <= 1; x++) {
      vec2 tileOffset = vec2(float(x), float(y));
      vec2 rand = do_randomGB(i_uv + tileOffset);
      vec2 cellCenter = vec2(0.5 + 1e-4);
      cellCenter += spreading * cos(time + TWO_PI * rand);
      cellCenter -= 0.5;
      cellCenter = do_rotate(cellCenter, do_randomR(vec2(rand.x, rand.y)) + 0.1 * time);
      cellCenter += 0.5;
      float dist = length(tileOffset + cellCenter - f_uv);
      if (dist < minDist) {
        minDist = dist;
        randomizer = rand;
      }
    }
  }

  return vec3(minDist, randomizer);
}

void main() {
  vec2 shape_uv = ps_patternUV();
  shape_uv *= 1.5;

  const float firstFrameOffset = -10.0;
  float t = u_time + firstFrameOffset;

  vec3 voronoi = do_voronoiShape(shape_uv, t) + 1e-4;

  float radius = 0.25 * clamp(u_size, 0.0, 1.0) - 0.5 * clamp(u_sizeRange, 0.0, 1.0) * voronoi[2];
  float dist = voronoi[0];
  float edgeWidth = ps_pixelDerivative(1.0);
  float dots = 1.0 - smoothstep(radius - edgeWidth, radius + edgeWidth, dist);

  float shape = voronoi[1];

  float mixer = shape * (u_colorsCount - 1.0);
  mixer = (shape - 0.5 / u_colorsCount) * u_colorsCount;
  float steps = max(1.0, u_stepsPerColor);

  vec4 gradient = do_colorAt(0);
  gradient.rgb *= gradient.a;
  for (int i = 1; i < 10; i++) {
    if (i >= int(u_colorsCount)) {
      break;
    }
    float localT = clamp(mixer - float(i - 1), 0.0, 1.0);
    localT = round(localT * steps) / steps;
    vec4 c = do_colorAt(i);
    c.rgb *= c.a;
    gradient = mix(gradient, c, localT);
  }

  if ((mixer < 0.0) || (mixer > (u_colorsCount - 1.0))) {
    float localT = mixer + 1.0;
    if (mixer > (u_colorsCount - 1.0)) {
      localT = mixer - (u_colorsCount - 1.0);
    }
    localT = round(localT * steps) / steps;
    vec4 cFst = do_colorAt(0);
    cFst.rgb *= cFst.a;
    vec4 cLast = do_colorAt(int(u_colorsCount - 1.0));
    cLast.rgb *= cLast.a;
    gradient = mix(cLast, cFst, localT);
  }

  vec3 color = gradient.rgb * dots;
  float opacity = gradient.a * dots;

  vec3 bgColor = u_colorBack.rgb * u_colorBack.a;
  color = color + bgColor * (1.0 - opacity);
  opacity = opacity + u_colorBack.a * (1.0 - opacity);

  fragColor = vec4(color, opacity);
}
