Shader "Custom/BlinnPhong"
{
    Properties
    {
        _AmbientLight ("Ambient Light", Color) = (0.25, 0.5, 0.5, 1)
        _MaterialKa("Ambient Material Ka", Color) = (0,0,0,0)
        _MaterialKd("Material Kd", Color) = (0,0,0,0)
        _MaterialKs("Material Ks", Color) = (0,0,0,0)
        _Material_n("Material n", float) = 1

        _PointLightColor ("Point Light Color", Color) = (1, 0, 0, 1)
        _PointLightIntensity ("Point Light Intensity", Color) = (1, 1, 1, 1)
        _PointLightPosition_w ("Point Light Position (World)", Vector) = (0, 5, 0, 1)

        _DirectionalLightIntensity ("Directional Light Intensity", Color) = (1, 1, 1, 1)
        _DirectionalLightDirection_w ("Directional Light Direction", Vector) = (0, 5, 0, 1)

        _SpotLightColor ("Spot Light Color", Color) = (1, 0, 0, 1)
        _SpotLightIntensity ("Spotlight Intensity", Color) = (1, 1, 1, 1)
        _SpotLightPosition_w ("Spotlight Position (World)", Vector) = (0, 5, 0, 1)
        _SpotLightDirection_w ("Spotlight Direction", Vector) = (0, 5, 0, 1)
        _SpotAperture ("Spot Aperture", Range(0.0, 90.0)) = 0.1
    }
    SubShader 
    {
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

            float4 _AmbientLight;
            float4 _MaterialKa;
            float4 _MaterialKd;
            float4 _MaterialKs;
            float _Material_n;

            float4 _PointLightIntensity;
            float4 _PointLightPosition_w;

            float4 _DirectionalLightIntensity;
            float4 _DirectionalLightDirection_w;

            float4 _SpotLightIntensity; 
            float4 _SpotLightPosition_w; 
            float4 _SpotLightDirection_w; 
            float _SpotAperture; 


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

                float3 ambient = _AmbientLight * _MaterialKa;

                // Point

                float3 point_L = normalize(_PointLightPosition_w.xyz - f.position_w.xyz);

                float3 pointDiffuse = _PointLightIntensity * _MaterialKd * max(0, dot(N,point_L));

                float3 V = normalize(_WorldSpaceCameraPos.xyz - f.position_w.xyz);
                float3 H = normalize(point_L + V); 

                float3 pointSpecular = _PointLightIntensity * _MaterialKs * pow(max(0,dot(H,N)),max(1,_Material_n));

                // Directional

                float directional_L = normalize(-(_DirectionalLightDirection_w.xyz));

                float3 directionalDiffuse = _DirectionalLightIntensity * _MaterialKd * (max(0, dot(directional_L, N)));
                
                V = normalize(_WorldSpaceCameraPos.xyz - f.position_w.xyz);
                H = normalize(directional_L + V);

                float3 directionalSpecular = _DirectionalLightIntensity * _MaterialKs * pow(max(0,dot(H,N)),max(1,_Material_n));

                // Spot

                float diffCoef = 0;
                float specCoef = 0;

                float3 spot_L = normalize(_SpotLightPosition_w.xyz - f.position_w.xyz);

                float cosenoDireccion = dot(-(_SpotLightDirection_w), spot_L);

                if (cosenoDireccion >= cos(radians(_SpotAperture)) ){
                    diffCoef = max(0,dot(N,spot_L));
                }

                float3 spotDiffuse = _SpotLightIntensity * _MaterialKd * (diffCoef);

                V = normalize(_WorldSpaceCameraPos.xyz - f.position_w.xyz);
                H = normalize(spot_L + V);

                if(cosenoDireccion >= cos(radians(_SpotAperture)) ){
                    specCoef = pow(max(0,dot(H, N)), max(1,_Material_n));
                }

                float3 spotSpecular = _SpotLightIntensity * _MaterialKs * specCoef;

                fragColor.rgb = ambient + pointDiffuse + pointSpecular + directionalDiffuse + directionalSpecular + spotDiffuse + spotSpecular;

                return fragColor;
            } 
            ENDCG
        }
    }
}
