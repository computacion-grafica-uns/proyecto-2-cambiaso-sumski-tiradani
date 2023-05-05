Shader "Custom/LuzSpot"
    {
    Properties {
        _MaterialColor ("Material Color", Color) = (0.25, 0.5, 0.5, 1)
        _LightColor ("Light Color", Color) = (0.25, 0.5, 0.5, 1)
        _LightPosition_w ("Light Position (World)", Vector) = (0, 5, 0, 1)
        _LightDirection_w ("Light Direction", Vector) = (0, 5, 0, 1)
        _Aperture ("Aperture", Range(0.0, 90.0)) = 0.1
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
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float4 position_w : TEXCOORD1;
                float3 normal_w : TEXCOORD0;
            };

            float4 _MaterialColor;
            float4 _LightPosition_w;
            float4 _LightDirection_w;
            float4 _LightColor;
            float _Aperture;

            v2f vertexShader(vertexData v){
                v2f output;
                output.vertex = UnityObjectToClipPos(v.position);
                output.position_w = mul(unity_ObjectToWorld, v.position);
                output.normal_w = UnityObjectToWorldNormal(v.normal);
                return output;
            }

            fixed4 fragmentShader(v2f f) : SV_Target {
                fixed4 fragColor = 0;

                float3 N = normalize(f.normal_w);
                float3 L = normalize(_LightPosition_w.xyz - f.position_w.xyz);
                float3 direccion = normalize(-(_LightDirection_w.xyz));
                float cosenoDireccion = dot(direccion,L);

                float diffCoef = 0;
                if (cosenoDireccion >= cos(radians(_Aperture)) ){
                    diffCoef = max(0,dot(N,L)) / distance(_LightPosition_w.xyz,f.position_w.xyz);
                }

                fragColor.rgb = diffCoef * _MaterialColor * _LightColor;
                return fragColor;
            } 
            ENDCG
        }
    }
}
