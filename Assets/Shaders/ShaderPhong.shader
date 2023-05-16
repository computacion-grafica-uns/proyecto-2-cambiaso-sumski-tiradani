Shader "Custom/ShaderPhong"
{
    Properties
    {
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}

        _PointLightColor ("Point Light Color", Color) = (1, 0, 0, 1)
        _PointLightPosition_w ("Point Light Position (World)", Vector) = (0, 5, 0, 1)

        _DirectionalLightColor ("Directional Light Color", Color) = (0, 1, 0, 1)
        _DirectionalLightDirection_w ("DirectionalLight Direction", Vector) = (0, -1, 0, 1)

        _SpotLightColor ("Spotlight Color", Color) = (0, 0, 1, 1)
        _SpotLightPosition_w ("Spotlight Position (World)", Vector) = (0, 2, 0, 1)
        _SpotLightDirection_w ("Spotlight Direction", Vector) = (0, -1, 0, 1)
        _SpotAperture ("Spotlight Aperture", Range(0.0, 90.0)) = 45


        _LightIntensity("LightIntensity", Color) = (1,1,1,1)
        _LightPosition_w("Light Position (World)", Vector) = (0,5,0,1)
        _AmbientLight("AmbientLight", Color) = (1,1,1,1)

        _MaterialKa("MaterialKa", Vector) = (0,0,0,0)
        _MaterialKd("MaterialKd", Vector) = (0,0,0,0)
        _MaterialKs("MaterialKs", Vector) = (0,0,0,0)
        _Material_n("Material_n", float) = 0.5
        
    }
    SubShader {
        Tags { "RenderType"="Opaque"}
        LOD 100

        Pass {
            CGPROGRAM
            #pragma vertex vertexShader
            #pragma fragment fragmentShader
            #include "UnityCG.cginc"

            struct vertexData {
                float4 position : POSITION;
                float3 normal : NORMAL;
                //float2 uv : TEXCOORD0;
            };

            struct v2f {
                //float4 vertex : SV_POSITION;
                //float4 position : POSITION_V;
                float4 position_w : TEXCOORD0;
                float3 normal_w : TEXCOORD1;
                //float2 uv : TEXCOORD2;
            };

            float4 _PointLightPosition_w;
            float4 _PointLightColor;

            float4 _DirectionalLightDirection_w;
            float4 _DirectionalLightColor;

            float4 _SpotLightPosition_w;
            float4 _SpotLightDirection_w;
            float4 _SpotLightColor;
            float _SpotAperture;

            float4 _AmbientLight;
            float4 _LightIntensity;
            float4 _LightPosition;

            float4 _MaterialKa;
            float4 _MaterialKd;
            float4 _MaterialKs;
            float _Material_n;

            sampler2D _MainTex;

            v2f vertexShader(vertexData v){
                v2f output;
                //output.position = UnityObjectToClipPos(v.position);
                output.position_w = mul(unity_ObjectToWorld, v.position);
                output.normal_w = UnityObjectToWorldNormal(v.normal);

                return output;
            }

            fixed4 fragmentShader(v2f f) : SV_Target {
                
                
                
                // Directional
                float3 N = normalize(f.normal_w);
                float diffCoef;
                float3 directional_L = normalize(-(_DirectionalLightDirection_w.xyz));
                //diffCoef = max(0, dot(N,directional_L));

                //Phong (Directional)
                
                float3 ambient = _AmbientLight * _MaterialKa;

                float3 diffuse = _LightIntensity * _MaterialKd * (max(0, dot(directional_L, N)));

                float3 R = reflect(directional_L, N);
                float3 V = normalize(_WorldSpaceCameraPos.xyz - f.position_w.xyz);
                float3 specular = _LightIntensity * _MaterialKs * (max(0,dot(R, V)));

                fixed4 iluminacionFinal = 0;
                iluminacionFinal.rgb = ambient + diffuse + specular; 

                return iluminacionFinal;
            } 
            ENDCG
        }
    }
}
