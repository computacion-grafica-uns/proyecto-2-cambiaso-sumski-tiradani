Shader "Custom/Shader2Texturas"
{
    Properties
    {
        // we have removed support for texture tiling/offset,
        // so make them not be displayed in material inspector
        [NoScaleOffset] _ColorTex ("Texture", 2D) = "white" {}
        [NoScaleOffset] _ShadowsTex ("Texture", 2D) = "white" {}

        _PointLightColor ("Point Light Color", Color) = (1, 0, 0, 1)
        _PointLightPosition_w ("Point Light Position (World)", Vector) = (0, 5, 0, 1)

        _SpotLightColor ("Spot Light Color", Color) = (1, 0, 0, 1)
        _SpotLightPosition_w ("Spot Light Position (World)", Vector) = (0, 5, 0, 1)

        _DirectionalLightColor ("Directional Light Color", Color) = (1, 0, 0, 1)
        _DirectionalLightDirection_w ("Directional Light Direction (World)", Vector) = (0, 5, 0, 1)

    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vertexShader
            #pragma fragment fragmentShader
            #include "UnityCG.cginc"

            float4 _PointLightPosition_w;
            float4 _PointLightColor;

            struct vertexData {
                float4 position : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float4 position_w : TEXCOORD0;
                float3 normal_w : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };
            
            // texture we will sample
            sampler2D _ColorTex;
            sampler2D _ShadowsTex;

            v2f vertexShader(vertexData v){
                v2f output;
                output.vertex = UnityObjectToClipPos(v.position);
                output.position_w = mul(unity_ObjectToWorld, v.position);
                output.normal_w = UnityObjectToWorldNormal(v.normal);
                output.uv = v.uv;
                return output;
            }

            fixed4 fragmentShader(v2f f) : SV_Target {
                float3 N = normalize(f.normal_w);
                                
                fixed4 fragColor = 0;
                float diffCoef;
                fixed4 pointColor = 0;



                // Textura
                fixed4 color = tex2D(_ColorTex, f.uv);
                float shadows = tex2D(_ShadowsTex, f.uv).r;

                // Point
                float3 L = normalize(_PointLightPosition_w.xyz - f.position_w.xyz);
                diffCoef = max(0, dot(N,L));

                pointColor = color;

                pointColor.rgb *= (1.0 - shadows)*5;

                return pointColor;
            } 
            ENDCG
        }
    }
}
