Shader "Custom/BlinnPhongTextura"
{
    Properties
    {
        _AmbientLight ("Ambient Light", Color) = (0.25, 0.5, 0.5, 1)
        _MaterialKa("Ambient Material Ka", Color) = (0,0,0,0)
        
        [NoScaleOffset] _MainText ("Texture", 2D) = "white" {}

        _PointLightIntensity ("Point Light Intensity", Color) = (1, 1, 1, 1)
        _PointLightPosition_w ("Point Light Position (World)", Vector) = (0, 5, 0, 1)
        _PointMaterialKs("Point Material Ks", Color) = (0,0,0,0)
        _PointMaterial_n("Point Material n", float) = 1

        _DirectionalLightIntensity ("Directional Light Intensity", Color) = (1, 1, 1, 1)
        _DirectionalLightDirection_w ("Directional Light Direction", Vector) = (0, 5, 0, 1)
        _DirectionalMaterialKs("Directional Material Ks", Color) = (0,0,0,0)
        _DirectionalMaterial_n("Directional Material n", float) = 1

        _SpotLightIntensity ("Spotlight Intensity", Color) = (1, 1, 1, 1)
        _SpotLightPosition_w ("Spotlight Position (World)", Vector) = (0, 5, 0, 1)
        _SpotLightDirection_w ("Spotlight Direction", Vector) = (0, 5, 0, 1)
        _SpotAperture ("Spot Aperture", Range(0.0, 90.0)) = 0.1
        _SpotMaterialKs("Spot Material Ks", Color) = (0,0,0,0)
        _SpotMaterial_n("Spot Material n", float) = 1
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
                float2 uv : TEXCOORD2;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float4 position_w : TEXCOORD1;
                float3 normal_w : TEXCOORD0;
                float2 uv : TEXCOORD2;
            };

            float4 _AmbientLight;
            float4 _MaterialKa;
            
            sampler2D _MainText;

            float4 _PointLightIntensity;
            float4 _PointLightPosition_w;
            float4 _PointMaterialKs;
            float _PointMaterial_n;

            float4 _DirectionalLightIntensity;
            float4 _DirectionalLightDirection_w;
            float4 _DirectionalMaterialKs;
            float _DirectionalMaterial_n;

            float4 _SpotLightIntensity; 
            float4 _SpotLightPosition_w; 
            float4 _SpotLightDirection_w; 
            float _SpotAperture; 
            float4 _SpotMaterialKs;
            float _SpotMaterial_n;


            v2f vertexShader(vertexData v){
                v2f output;
                output.vertex = UnityObjectToClipPos(v.position);
                output.position_w = mul(unity_ObjectToWorld, v.position);
                output.normal_w = UnityObjectToWorldNormal(v.normal);
                output.uv = v.uv;
                return output;
            }

            fixed4 fragmentShader(v2f f) : SV_Target {
                fixed4 fragColor = 0;
                float3 N = normalize(f.normal_w);

                float3 ambient = _AmbientLight * _MaterialKa;

                // Kd basado en la textura

                fixed4 _MaterialKd = tex2D(_MainText, f.uv);

                // Point

                float3 point_L = normalize(_PointLightPosition_w.xyz - f.position_w.xyz);

                float3 pointDiffuse = _PointLightIntensity * _MaterialKd * max(0, dot(N,point_L));

                float3 V = normalize(_WorldSpaceCameraPos.xyz - f.position_w.xyz);
                float3 H = (point_L + V) / 2; 

                float3 pointSpecular = _PointLightIntensity * _PointMaterialKs * pow(max(0,dot(H,N)),max(1,_PointMaterial_n));

                // Directional

                float directional_L = normalize(-(_DirectionalLightDirection_w.xyz));

                float3 directionalDiffuse = _DirectionalLightIntensity * _MaterialKd * (max(0, dot(directional_L, N)));
                
                V = normalize(_WorldSpaceCameraPos.xyz - f.position_w.xyz);
                H = (directional_L + V)/2;

                float3 directionalSpecular = _DirectionalLightIntensity * _DirectionalMaterialKs * pow(max(0,dot(H,N)),max(1,_DirectionalMaterial_n));

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
                H = (spot_L + V)/2;

                if(cosenoDireccion >= cos(radians(_SpotAperture)) ){
                    specCoef = pow(max(0,dot(H, N)), max(1,_SpotMaterial_n));
                }

                float3 spotSpecular = _SpotLightIntensity * _SpotMaterialKs * specCoef;

                fragColor.rgb = ambient + pointDiffuse + pointSpecular + directionalDiffuse + directionalSpecular + spotDiffuse + spotSpecular;

                return fragColor;

            } 
            ENDCG
        }
    }
}
