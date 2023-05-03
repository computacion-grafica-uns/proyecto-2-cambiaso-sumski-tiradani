Shader "Custom/ShaderDifuso"
{
    Properties
    {
        _MaterialColor ("Material Color", Color) = (0.25, 0.5, 0.5, 1)
        _LightPosition_w ("Light Position (World)", Vector) = (0, 5, 0, 1)
        _LightColor_w ("Light Color (World)", Color) = (1, 1, 0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass{
            CGPROGRAM
            #pragma vertex vertexShader
            #pragma fragment fragmentShader
            #include "UnityCG.cginc"
            
            struct vertexData
            {
                float4 position : POSITION; // Object space
                float3 normal : NORMAL; // Object space
            };

            struct v2f
            {
                float4 position : SV_POSITION; // Clipping space
                float4 position_w : W_POSITION; // World space
                float3 normal_w : W_NORMAL; // World normal
            };

            float4 _MaterialColor;
            float4 _LightPosition_w;
            float4 _LightColor_w;

            v2f vertexShader(vertexData v){
                v2f output;
                output.position_w = mul(unity_ObjectToWorld, v.position);
                output.normal_w = normalize(UnityObjectToWorldNormal(v.normal));
                output.position = UnityObjectToClipPos(v.position);

                return output;
            }

            fixed4 fragmentShader (v2f f) : SV_Target {
                float3 L = normalize(_LightPosition_w.xyz - f.position_w.xyz); 
                float3 N = f.normal_w;

                fixed4 fragColor = 0;
                fragColor.rgb = max(0, dot(N,L)) * _MaterialColor * _LightColor_w;
                return fragColor;
            }
            ENDCG
        }
    }
}
