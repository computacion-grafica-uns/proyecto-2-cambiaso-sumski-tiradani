Shader "Custom/Cel"
{
    Properties
    {
        _Treshold ("Cel treshold", Range(1., 20.)) = 5.

        _AmbientLight ("Ambient Light", Color) = (0.25, 0.5, 0.5, 1)
        _MaterialKa("Ambient Material Ka", Color) = (0,0,0,0)
        _MaterialKd("Material Kd", Color) = (0,0,0,0)

        _PointLightColor ("Point Light Color", Color) = (1, 0, 0, 1)
        _PointLightIntensity ("Point Light Intensity", Color) = (1, 1, 1, 1)
        _PointLightPosition_w ("Point Light Position (World)", Vector) = (0, 5, 0, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque"}
        LOD 100
 
        Pass
        {
            CGPROGRAM
            #pragma vertex vertexShader
            #pragma fragment frag
            #include "UnityCG.cginc"
 
            struct vertexData {
                float4 position : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float4 position_w : TEXCOORD1;
                float3 normal_w : TEXCOORD2;
            };

            float4 _AmbientLight;
            float4 _MaterialKa;
            float4 _MaterialKd;

            float _Treshold;
            float4 _PointLightIntensity;
            float4 _PointLightPosition_w;
 
            float LightToonShading(float3 normal, float3 lightDir)
            {
                float NdotL = max(0.0, dot(normalize(normal), normalize(lightDir)));
                return floor(NdotL * _Treshold) / (_Treshold - 0.5);
            }
 
            sampler2D _MainTex;
            float4 _MainTex_ST;
 
            v2f vertexShader(vertexData v){
                v2f output;
                output.vertex = UnityObjectToClipPos(v.position);
                output.position_w = mul(unity_ObjectToWorld, v.position);
                output.normal_w = UnityObjectToWorldNormal(v.normal);
                return output;
            }
 
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 fragColor = 0;
                float3 ambient = _AmbientLight * _MaterialKa;

                float3 point_L = normalize(_PointLightPosition_w.xyz - i.position_w.xyz);
                float3 pointDiffuse = _PointLightIntensity * _MaterialKd * saturate(LightToonShading(i.normal_w,point_L));

                fragColor.rgb = ambient +  pointDiffuse;
                return fragColor;
            }
            ENDCG
        }
    }
}