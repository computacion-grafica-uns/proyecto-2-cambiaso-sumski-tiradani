Shader "Custom/Cel"
{
    Properties
    {
        _Treshold ("Cel treshold", Range(1., 20.)) = 5.

        _AmbientLight ("Ambient Light", Color) = (0.25, 0.5, 0.5, 1)
        _MaterialKa("Ambient Material Ka", Color) = (0,0,0,0)
        _MaterialKd("Material Kd", Color) = (0,0,0,0)
        _MaterialKs("Material Ks", Color) = (0,0,0,0)
        _Glossiness("Glossiness", Float) = 32

        _PointLightColor ("Point Light Color", Color) = (1, 0, 0, 1)
        _PointLightIntensity ("Point Light Intensity", Range(0.0, 1.0)) = 0.5
        _PointLightPosition_w ("Point Light Position (World)", Vector) = (0, 5, 0, 1)

        _DirectionalLightColor ("Directional Light Color", Color) = (1, 0, 0, 1)
        _DirectionalLightIntensity ("Directional Light Intensity", Range(0.0, 1.0)) = 0.5
        _DirectionalLightDirection_w ("Directional Light Direction", Vector) = (0, 5, 0, 1)

        _SpotLightColor ("Spot Light Color", Color) = (1, 0, 0, 1)
        _SpotLightIntensity ("Spotlight Intensity", Range(0.0, 1.0)) = 0.5
        _SpotLightPosition_w ("Spotlight Position (World)", Vector) = (0, 5, 0, 1)
        _SpotLightDirection_w ("Spotlight Direction", Vector) = (0, 5, 0, 1)
        _SpotAperture ("Spot Aperture", Range(0.0, 90.0)) = 0.1
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
            float4 _MaterialKs;
            
			float _Glossiness;	
            float _Treshold;

            float _PointLightIntensity;
            float4 _PointLightColor;
            float4 _PointLightPosition_w;

            float4 _DirectionalLightColor;
            float _DirectionalLightIntensity;
            float4 _DirectionalLightDirection_w;

            float4 _SpotLightColor;
            float _SpotLightIntensity; 
            float4 _SpotLightPosition_w; 
            float4 _SpotLightDirection_w; 
            float _SpotAperture; 
 
            float CelShading(float3 normal, float3 lightDir)
            {
                float NdotL = max(0.0, dot(normal, lightDir));
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
                float3 N = normalize(i.normal_w);
                float3 V = normalize(_WorldSpaceCameraPos.xyz - i.position_w.xyz);

                //Point
                float3 point_L = normalize(_PointLightPosition_w.xyz - i.position_w.xyz);
                float3 pointDiffuse = _PointLightIntensity * _PointLightColor * _MaterialKd * saturate(CelShading(N,point_L));

                float3 H = normalize(point_L + V);
                float NdotH = max(0,dot(H,N));
                float3 pointSpecular = smoothstep(0.005, 0.01, pow(NdotH * _PointLightIntensity, _Glossiness * _Glossiness)) * _MaterialKs * _PointLightColor;	
                    
                //Directional
                float3 directional_L = normalize(-(_DirectionalLightDirection_w.xyz));
                float3 directionalDiffuse = _DirectionalLightIntensity * _DirectionalLightColor * _MaterialKd * saturate(CelShading(N,directional_L));

                H = normalize(directional_L + V);
                NdotH = max(0,dot(H,N));
                float3 directionalSpecular = smoothstep(0.005, 0.01, pow(NdotH * _DirectionalLightIntensity, _Glossiness * _Glossiness)) * _MaterialKs * _DirectionalLightColor;	

                //Spot
                float diffCoef = 0;
                float specCoef = 0;
                float3 spot_L = normalize(_SpotLightPosition_w.xyz - i.position_w.xyz);
                float cosenoDireccion = dot(-(_SpotLightDirection_w), spot_L);

                if (cosenoDireccion >= cos(radians(_SpotAperture)) ){
                    diffCoef = saturate(CelShading(N,point_L));
                }
                float3 spotDiffuse = _SpotLightIntensity * _SpotLightColor * _MaterialKd * (diffCoef);

                H = normalize(spot_L + V);
                NdotH = max(0,dot(H,N));
                if(cosenoDireccion >= cos(radians(_SpotAperture)) ){
                    specCoef = smoothstep(0.005, 0.01, pow(NdotH * _SpotLightIntensity, _Glossiness * _Glossiness));
                }
                float3 spotSpecular = specCoef * _MaterialKs * _SpotLightColor;


                fragColor.rgb = ambient + pointDiffuse + pointSpecular + directionalDiffuse + directionalSpecular + spotDiffuse + spotSpecular;
                return fragColor;
            }
            ENDCG
        }
    }
}