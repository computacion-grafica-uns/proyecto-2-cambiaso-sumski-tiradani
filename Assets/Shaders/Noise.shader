Shader "Custom/Noise"
{
    Properties
    {
        _Factor1 ("Factor 1", float) = 1
        _Factor2 ("Factor 2", float) = 1
        _Factor3 ("Factor 3", float) = 1
        _FactorMultiplicacion("Factor Multiplicacion", float) = 1
        _SpotLightColor ("Spot Light Color", Color) = (1, 0, 0, 1)
        _PointLightColor ("Point Light Color", Color) = (1, 0, 0, 1)
        _PointLightIntensity ("Point Light Intensity", Range(0.0, 1.0)) = 0.5
        _PointLightPosition_w ("Point Light Position (World)", Vector) = (0, 5, 0, 1)

        _DirectionalLightColor ("Directional Light Color", Color) = (1, 0, 0, 1)
        _DirectionalLightIntensity ("Directional Light Intensity", Range(0.0, 1.0)) = 0.5
        _DirectionalLightDirection_w ("Directional Light Direction", Vector) = (0, 5, 0, 1)
    }
 
    SubShader
    {
        Tags { "RenderType"="Opaque" }
 
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
           
            #include "UnityCG.cginc"
           
            float _Factor1;
            float _Factor2;
            float _Factor3;
            float _FactorMultiplicacion;
            float4 _SpotLightColor;

            float4 _PointLightColor;
            float _PointLightIntensity;
            float4 _PointLightPosition_w;

            float4 _DirectionalLightColor;
            float _DirectionalLightIntensity;
            float4 _DirectionalLightDirection_w;

            struct vertexData {
                float4 position : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 position_w : TEXCOORD1;
                float3 normal_w : TEXCOORD2;
            };

            v2f vertexShader(vertexData v){
                v2f output;
                output.vertex = UnityObjectToClipPos(v.position);
                output.position_w = mul(unity_ObjectToWorld, v.position);
                output.normal_w = UnityObjectToWorldNormal(v.normal);
                output.uv = v.uv;
                return output;
            }

            float noise(half2 uv)
            {
                return frac(sin(dot(uv, float2(_Factor1, _Factor2))) * _Factor3);
            }
 
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = noise(i.uv);
                if (_SpotLightColor.r == 0 && _SpotLightColor.g == 0 && _SpotLightColor.b == 0)
                {
                    return float4(0,0,0,1);
                }
                    

                return col*_FactorMultiplicacion;
            }
            ENDCG
        }
    }
}