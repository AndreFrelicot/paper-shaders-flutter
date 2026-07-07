#include <flutter/runtime_effect.glsl>
#include "common/sizing.glsl"
#include "common/utils.glsl"

uniform sampler2D u_image;

uniform vec4 u_colorBack;
uniform vec4 u_colorHighlight;
uniform float u_highlights;
uniform float u_layering;
uniform float u_edges;
uniform float u_caustic;
uniform float u_waves;
uniform float u_size;

out vec4 fragColor;

float waterGetUvFrame(vec2 uv) {
  float aa = 2. * ps_pixelDerivative(1.0);

  float left = smoothstep(0., aa, uv.x);
  float right = 1.0 - smoothstep(1. - aa, 1., uv.x);
  float bottom = smoothstep(0., aa, uv.y);
  float top = 1.0 - smoothstep(1. - aa, 1., uv.y);

  return left * right * bottom * top;
}

mat2 waterRotate2D(float r) {
  return mat2(cos(r), sin(r), -sin(r), cos(r));
}

float waterGetCausticNoise(vec2 uv, float t, float scale) {
  vec2 n = vec2(.1);
  vec2 N = vec2(.1);
  mat2 m = waterRotate2D(.5);
  for (int j = 0; j < 6; j++) {
    uv *= m;
    n *= m;
    float fj = float(j);
    vec2 q = uv * scale + fj + n + (.5 + .5 * fj) * (glsl_mod(fj, 2.) - 1.) * t;
    n += sin(q);
    N += cos(q) / scale;
    scale *= 1.1;
  }
  return N.x + N.y + 1.;
}

void main() {
  vec2 imageUV = ps_imageUV();
  vec2 patternUV = ps_imageUV() - .5;
  patternUV = patternUV * vec2(u_imageAspectRatio, 1.);
  patternUV /= (.01 + .09 * u_size);

  float t = u_time;

  float wavesNoise = snoise((.3 + .1 * sin(t)) * .1 * patternUV + vec2(0., .4 * t));

  float causticNoise = waterGetCausticNoise(patternUV + u_waves * vec2(1., -1.) * wavesNoise, 2. * t, 1.5);

  causticNoise += u_layering * waterGetCausticNoise(patternUV + 2. * u_waves * vec2(1., -1.) * wavesNoise, 1.5 * t, 2.);
  causticNoise = causticNoise * causticNoise;

  float edgesDistortion = smoothstep(0., .1, imageUV.x);
  edgesDistortion *= smoothstep(0., .1, imageUV.y);
  edgesDistortion *= (smoothstep(1., 1.1, imageUV.x) + (1.0 - smoothstep(.8, .95, imageUV.x)));
  edgesDistortion *= (1.0 - smoothstep(.9, 1., imageUV.y));
  edgesDistortion = mix(edgesDistortion, 1., u_edges);

  float causticNoiseDistortion = .02 * causticNoise * edgesDistortion;
  float wavesDistortion = .1 * u_waves * wavesNoise;

  imageUV += vec2(wavesDistortion, -wavesDistortion);
  imageUV += u_caustic * causticNoiseDistortion;

  float frame = waterGetUvFrame(imageUV);

  vec4 image = texture(u_image, imageUV);
  vec4 backColor = u_colorBack;
  backColor.rgb *= backColor.a;

  vec3 color = mix(backColor.rgb, image.rgb, image.a * frame);
  float opacity = backColor.a + image.a * frame;

  causticNoise = max(-.2, causticNoise);

  float hightlight = .025 * u_highlights * causticNoise;
  hightlight *= u_colorHighlight.a;
  color = mix(color, u_colorHighlight.rgb, .05 * u_highlights * causticNoise);
  opacity += hightlight;

  color += hightlight * (.5 + .5 * wavesNoise);
  opacity += hightlight * (.5 + .5 * wavesNoise);

  opacity = clamp(opacity, 0., 1.);

  fragColor = vec4(color, opacity);
}
