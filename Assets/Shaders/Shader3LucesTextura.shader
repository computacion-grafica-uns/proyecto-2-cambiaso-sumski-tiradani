Shader "Custom/Shader3LucesTextura"
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
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float4 position_w : TEXCOORD0;
                float3 normal_w : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            float4 _PointLightPosition_w;
            float4 _PointLightColor;

            float4 _DirectionalLightDirection_w;
            float4 _DirectionalLightColor;

            float4 _SpotLightPosition_w;
            float4 _SpotLightDirection_w;
            float4 _SpotLightColor;
            float _SpotAperture;

            sampler2D _MainTex;

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
                fixed4 directColor = 0;
                fixed4 spotColor = 0;

                // Textura
                fixed4 col = tex2D(_MainTex, f.uv);
                
                // Point
                float3 L = normalize(_PointLightPosition_w.xyz - f.position_w.xyz);
                diffCoef = max(0, dot(N,L));
                pointColor.rgb = diffCoef * col.rgb * _PointLightColor;

                // Directional
                float3 directional_L = normalize(-(_DirectionalLightDirection_w.xyz));
                diffCoef = max(0, dot(N,directional_L));
                directColor.rgb = diffCoef * col.rgb * _DirectionalLightColor;

                // Spotlight
                float3 spot_L = normalize(_SpotLightPosition_w.xyz - f.position_w.xyz);
                float3 direccion = normalize(-(_SpotLightDirection_w.xyz));
                float cosenoDireccion = dot(direccion,spot_L);

                if (cosenoDireccion >= cos(radians(_SpotAperture)) ){
                    diffCoef = max(0,dot(N,spot_L));
                } else {
                    diffCoef = 0;
                }
                spotColor.rgb = diffCoef * col.rgb * _SpotLightColor;

                // Suma de las luces
                fragColor.rgb = pointColor.rgb + directColor.rgb + spotColor.rgb;
                return fragColor;
            } 
            ENDCG
        }
    }
}
