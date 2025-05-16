struct VSIN
{
    float2 Position : POSITION0; // Quad vertex, e.g. [-0.5, 0.5]
    float2 TexCoords : TEXCOORD0;

    float2 InstancePos : TEXCOORD1; // New: instance center position
    float2 InstanceScale : TEXCOORD2; // New: scale (line length, thickness)
    float InstanceRot : TEXCOORD3; // New: rotation in radians
    float4 InstanceColor : COLOR0;
#if defined(COMPILE_FOR_TEXT)
    float4 UVRect           : TEXCOORD4;
    float Fatness           : TEXCOORD5;
#endif
    float InstanceLayer : LAYER0;
};

struct PSIN
{
    float4 PositionWS : SV_POSITION;
    float2 TexCoords : TEXCOORD0;
    float4 Color : COLOR0;
#if defined(COMPILE_FOR_TEXT)
    float2 UV               : TEXCOORD1;
    float Fatness           : TEXCOORD2;
#endif
};

PSIN main(VSIN Input)
{
    PSIN Output;

    // Reconstruct transform matrix from TRS
    float cosA = cos(Input.InstanceRot);
    float sinA = sin(Input.InstanceRot);

    float2 local = Input.Position * Input.InstanceScale;

    float2 rotated = float2(
        local.x * cosA - local.y * sinA,
        local.x * sinA + local.y * cosA
    );

    float2 worldPos = Input.InstancePos + rotated;

    // Normalize to screen space
    Output.PositionWS = float4(worldPos.x / 1850.0f, worldPos.y / 1000.0f, Input.InstanceLayer, 1.0f);

    Output.TexCoords = Input.TexCoords;
    Output.Color = Input.InstanceColor;

#if defined(COMPILE_FOR_TEXT)
    float2 textureSize = 1.0f / float2(1024.0f, 512.0f);
    float2 clampedTexCoords = saturate(Input.TexCoords);
    Output.UV = lerp(Input.UVRect.xy * textureSize, Input.UVRect.zw * textureSize, clampedTexCoords);
    Output.Fatness = saturate(Input.Fatness);
#endif

    return Output;
}
