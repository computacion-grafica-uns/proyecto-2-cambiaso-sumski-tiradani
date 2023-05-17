Shader "Custom/CookTorranceTextura"
{
Properties
    {
        _AmbientLight ("Ambient Light", Color) = (0.25, 0.5, 0.5, 1)
        _AmbientMaterial("Ambient Material", Color) = (0,0,0,0)

        [NoScaleOffset] _MainText ("Texture", 2D) = "white" {}
        _Roughness ("Roughness", Range(0, 1)) = 0.5
        _Metallic ("Metallic", Range(0, 1)) = 0.5

        _PointLightColor("Point Light Color", Color) = (0,0,0,0)
        _PointLightIntensity ("Point Light Intensity", Color) = (1, 1, 1, 1)
        _PointLightPosition_w ("Point Light Position (World)", Vector) = (0, 5, 0, 1)

        _DirectionalLightColor ("Directional Light Color", Color) = (0,0,0,0)
        _DirectionalLightIntensity ("Directional Light Intensity", Color) = (1, 1, 1, 1)
        _DirectionalLightDirection_w ("Directional Light Direction", Vector) = (0, 5, 0, 1)

        _SpotLightColor("Spotlight Color", Color) = (0,0,0,0)
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

            #define PI 3.14159265359f

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

            float4 _AmbientLight;
            float4 _AmbientMaterial;

            sampler2D _MainText;
            float _Roughness;
            float _Metallic;

            float4 _PointLightIntensity;
            float4 _PointLightPosition_w;
            float4 _PointLightColor;

            float4 _DirectionalLightIntensity;
            float4 _DirectionalLightDirection_w;
            float4 _DirectionalLightColor;

            float4 _SpotLightIntensity; 
            float4 _SpotLightPosition_w; 
            float4 _SpotLightDirection_w; 
            float _SpotAperture; 
            float4 _SpotLightColor;

            v2f vertexShader(vertexData v){
                v2f output;
                output.vertex = UnityObjectToClipPos(v.position);
                output.position_w = mul(unity_ObjectToWorld, v.position);
                output.normal_w = UnityObjectToWorldNormal(v.normal);
                output.uv = v.uv;
                return output;
            }

            float F(float3 V, float3 H){
                float VdotH = max(dot(V, H),0); 

                return _Metallic + (1.0 - _Metallic) * pow(1.0 - VdotH, 5);;
            }

            float D(float3 H, float3 N){
                float NdotH = max(dot(N, H),0);

                return pow(_Roughness,4) / (PI * pow(NdotH * NdotH * (pow(_Roughness,4) - 1.0) + 1.0, 2));
            }

            float G(float3 L, float3 V, float3 N){
                float NdotL = max(dot(N, L),0);
                float NdotV = max(dot(N, V),0);
                float k  = _Roughness * _Roughness / 2.0;

                float gl = NdotL / (NdotL * (1.0 - k) + k);
                float gv = NdotV / (NdotV * (1.0 - k) + k);
                return gl * gv;
            }

            fixed4 fragmentShader(v2f f) : SV_Target {
                fixed4 fragColor = 0;

                fixed4 color = tex2D(_MainText, f.uv);
                float3 ambient = _AmbientLight * _AmbientMaterial;

                // Point
                float3 N = normalize(f.normal_w);
                float3 L = normalize(_PointLightPosition_w.xyz - f.position_w.xyz);
                float3 V = normalize(_WorldSpaceCameraPos.xyz - f.position_w.xyz);
                float3 H = (L + V) / 2; 

                // Point Diffuse
                float3 pointDiffuse = max(0, dot(N, L)) * color.rgb * _PointLightIntensity * _PointLightColor;

                // Point Specular Cook-Torrance
                float NdotL = max(0,dot(N, L));
                float NdotV = max(0,dot(N, V));
                float3 pointSpecular = max(0, F(V,H) * D(H,N) * G(L,V,N) / (4.0 * NdotV * NdotL) * _PointLightIntensity * _PointLightColor);

                // Directional
                L = normalize(-(_DirectionalLightDirection_w.xyz));
                H = (L + V)/2;

                // Directional Diffuse
                float3 directionalDiffuse = color.rgb; //max(0, saturate(dot(N, L))) * _Albedo.rgb * _DirectionalLightIntensity * _DirectionalLightColor ;
 
                // Directional Specular Cook-Torrance
                NdotL = max(0, dot(N, L));
                NdotV = max(0, dot(N, V));
                float3 directionalSpecular = ((F(V,H) * D(H,N) * G(L,V,N) / (4.0 * NdotV * NdotL)) * _DirectionalLightIntensity * _DirectionalLightColor) ;

                // Spot

                L = normalize(_SpotLightPosition_w.xyz - f.position_w.xyz);
                H = (L + V)/2;
                float cosenoDireccion = dot(-(_SpotLightDirection_w), L);
                NdotL = max(0,dot(N, L));
                NdotV = max(0,dot(N, V));
                
                float3 spotDiffuse = 0;
                float3 spotSpecular = 0;

                // Spot Diffuse

                if (cosenoDireccion >= cos(radians(_SpotAperture)) ){
                    spotDiffuse = color.rgb; // max(0, saturate(dot(N, L))) * color.rgb  * _SpotLightIntensity * _SpotLightColor;
                }

                // Spot Specular Cook-Torrance
                if (cosenoDireccion >= cos(radians(_SpotAperture)) ){
                    spotSpecular = ((F(V,H) * D(H,N) * G(L,V,N)) / (4.0 * NdotV * NdotL) * _SpotLightIntensity * _SpotLightColor) ;
                }

                fragColor.rgb = ambient + pointDiffuse + pointSpecular; //+ directionalDiffuse + directionalSpecular + spotDiffuse + spotSpecular; // ambient + pointDiffuse + pointSpecular + directionalDiffuse + directionalSpecular + spotDiffuse + spotSpecular;

                return fragColor;
            } 
            ENDCG
        }
    }
}
