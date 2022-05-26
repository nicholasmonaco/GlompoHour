#include "../_Imports/3D Noise/HLSL/ClassicNoise3D.hlsl" 


float4 hash4(float2 p) { 
    return frac(sin(float4(1.0 + dot(p, float2(37.0, 17.0)), 
                           2.0 + dot(p, float2(11.0, 47.0)),
                           3.0 + dot(p, float2(41.0, 29.0)),
                           4.0 + dot(p, float2(23.0, 31.0)))) * 103.0); 
}

float4 tech01(SamplerState samp, Texture2D tex, in float2 uv) {
    int2 iuv = int2(floor(uv));
    float2 fuv = frac(uv);

    // Generate per-tile transform
    float4 ofa = hash4(iuv + int2(0, 0));
    float4 ofb = hash4(iuv + int2(1, 0));
    float4 ofc = hash4(iuv + int2(0, 1));
    float4 ofd = hash4(iuv + int2(1, 1));

    float2 dx = ddx(uv);
    float2 dy = ddy(uv);

    // Transform per-tile uvs
    ofa.zw = sign(ofa.zw - 0.5);
    ofb.zw = sign(ofb.zw - 0.5);
    ofc.zw = sign(ofc.zw - 0.5);
    ofd.zw = sign(ofd.zw - 0.5);

    // UV's and derivatives (for correct mipmapping)
    float2 uva = uv * ofa.zw + ofa.xy;
    float2 dxa = dx * ofa.zw;
    float2 dya = dy * ofa.zw;
    
    float2 uvb = uv * ofb.zw + ofb.xy;
    float2 dxb = dx * ofb.zw;
    float2 dyb = dy * ofb.zw;
    
    float2 uvc = uv * ofc.zw + ofc.xy;
    float2 dxc = dx * ofc.zw;
    float2 dyc = dy * ofc.zw;
    
    float2 uvd = uv * ofd.zw + ofd.xy; 
    float2 dxd = dx * ofd.zw;
    float2 dyd = dy * ofd.zw;


    // Fetch and blend
    float2 b = smoothstep(0.25, 0.75, fuv);

    return lerp(lerp(tex.SampleGrad(samp, uva, dxa, dya), 
                     tex.SampleGrad(samp, uvb, dxb, dyb), b.x),
                lerp(tex.SampleGrad(samp, uvc, dxc, dyc),
                     tex.SampleGrad(samp, uvd, dxd, dyd), b.x), b.y);
}


float edgeNoise(float3 position, int octaveCount, float amplitude, float frequency, float persistence, float lacunarity) {
    float value = 0;
    for(int i = 0; i < octaveCount; i++) {
        value += amplitude * cnoise(position * frequency);
        amplitude *= persistence;
        frequency *= lacunarity;
    }

    return value;
}




void OctaveNoise_float(float3 Position, int OctaveCount, float Amplitude, float Frequency, float Persistence, float Lacunarity, out float Out) {
    Out = edgeNoise(Position, OctaveCount, Amplitude, Frequency, Persistence, Lacunarity);
}


void Tech01_float(in SamplerState Sampler, in Texture2D Texture, float2 UV, out float4 Out) {
    Out = tech01(Sampler, Texture, UV);
} 