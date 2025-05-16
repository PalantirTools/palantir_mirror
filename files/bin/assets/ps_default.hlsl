#if defined(COMPILE_FOR_TEXT)
Texture2D font_texture : register(t0);
SamplerState default_sampler : register(s0);
#endif

struct PSIN
{
    float4 PositionWS : SV_POSITION;
    float2 TexCoords : TEXCOORD0;
    float4 Color : COLOR0;
#if defined(COMPILE_FOR_TEXT)
    float2 UV : TEXCOORD1;
    float Fatness : TEXCOORD2;
#endif
};

float4 main(PSIN Input) : SV_TARGET
{
#if defined(COMPILE_FOR_TEXT)
    float4 sdf = font_texture.Sample(default_sampler, Input.UV);
    
    float edge = lerp(0.42f, 0.49, 1.0f - Input.Fatness);
    float smoothness = lerp(0.03f, 0.05f, 1.0f - Input.Fatness);

    float alpha = smoothstep(edge - smoothness, edge + smoothness, sdf.r);

    return float4(Input.Color.rgb * alpha, alpha);
#endif
    return Input.Color;
}
