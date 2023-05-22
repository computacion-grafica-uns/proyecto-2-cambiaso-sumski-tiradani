Shader "Custom/ShaderMultitexturaGotasAgua"
{
    Properties
    {
        [NoScaleOffset] _ColorTex ("Texture", 2D) = "white" {}
        [NoScaleOffset] _ShadowsTex ("Texture", 2D) = "white" {}
        _MaterialKs("Material Ks", Color) = (0,0,0,0)
        _Material_n("Material n", float) = 1

        _PointLightColor ("Point Light Color", Color) = (1, 0, 0, 1)        
        _PointLightIntensity ("Point Light Intensity", Range(0.0, 1.0)) = 0.5
        _PointLightPosition_w ("Point Light Position (World)", Vector) = (0, 5, 0, 1)

        _DirectionalLightColor ("Directional Light Color", Color) = (1, 0, 0, 1)
        _DirectionalLightIntensity ("Directional Light Intensity", Range(0.0, 1.0)) = 0.5
        _DirectionalLightDirection_w ("Directional Light Direction (World)", Vector) = (0, 5, 0, 1)

        _SpotLightColor ("Spot Light Color", Color) = (1, 0, 0, 1)
        _SpotLightIntensity ("Spotlight Intensity", Range(0.0, 1.0)) = 0.5
        _SpotLightPosition_w ("Spot Light Position (World)", Vector) = (0, 5, 0, 1)
        _SpotLightDirection_w ("Spotlight Direction", Vector) = (0, 5, 0, 1)
        _SpotAperture ("Spot Aperture", Range(0.0, 90.0)) = 0.1
    }
    SubShader
    {
        Pass
        {
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
            
            // Texturas
            sampler2D _ColorTex;
            sampler2D _ShadowsTex;

            // Luces
            float4 _AmbientLight;
            float4 _MaterialKa;
            float4 _MaterialKs;
            float _Material_n;
            
            sampler2D _MainText;

            float4 _PointLightColor;
            float _PointLightIntensity;
            float4 _PointLightPosition_w;

            float4 _DirectionalLightColor;
            float _DirectionalLightIntensity;
            float4 _DirectionalLightDirection_w;

            float4 _SpotLightColor;
            float _SpotLightIntensity; 
            float4 _SpotLightPosition_w; 
            float4 _SpotLightDirection_w; 
            float _SpotAperture; 

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

                float3 ambient = _AmbientLight * _MaterialKa;
                float3 _MaterialKd;

                // Textura
                fixed4 mainTex = tex2D(_ColorTex, f.uv);
                fixed4 gotas = tex2D(_ShadowsTex, f.uv);

                // Textures
                if(gotas.b > 0.03f)
                {
                    _MaterialKd = float3(gotas.r/2,gotas.g/2,gotas.b*3);
                    _MaterialKs = float4(1,1,1,1);
                    _Material_n = _Material_n * 30;
                }else
                {
                    _MaterialKd = mainTex;
                }

                // Point
                float3 point_L = normalize(_PointLightPosition_w.xyz - f.position_w.xyz);

                float3 pointDiffuse = _PointLightIntensity * _PointLightColor * _MaterialKd * max(0, dot(N,point_L));

                float3 V = normalize(_WorldSpaceCameraPos.xyz - f.position_w.xyz);
                float3 H = normalize(point_L + V); 

                float3 pointSpecular = _PointLightIntensity * _PointLightColor * _MaterialKs * pow(max(0,dot(H,N)),max(1,_Material_n));

                // Directional

                float3 directional_L = normalize(-(_DirectionalLightDirection_w.xyz));

                float3 directionalDiffuse = _MaterialKd * _DirectionalLightIntensity * _DirectionalLightColor * max(0, dot(N,directional_L));
                
                V = normalize(_WorldSpaceCameraPos.xyz - f.position_w.xyz);
                H = normalize(directional_L + V);

                float3 directionalSpecular = _DirectionalLightIntensity * _DirectionalLightColor * _MaterialKs * pow(max(0,dot(H,N)),max(1,_Material_n));

                // Spot

                diffCoef = 0;
                float specCoef = 0;

                float3 spot_L = normalize(_SpotLightPosition_w.xyz - f.position_w.xyz);

                float cosenoDireccion = dot(-(_SpotLightDirection_w), spot_L);

                if (cosenoDireccion >= cos(radians(_SpotAperture)) ){
                    diffCoef = max(0,dot(N,spot_L));
                }

                float3 spotDiffuse = _SpotLightIntensity * _SpotLightColor * _MaterialKd * (diffCoef);

                V = normalize(_WorldSpaceCameraPos.xyz - f.position_w.xyz);
                H = normalize(spot_L + V);

                if(cosenoDireccion >= cos(radians(_SpotAperture)) ){
                    specCoef = pow(max(0,dot(H, N)), max(1,_Material_n));
                }

                float3 spotSpecular = _SpotLightIntensity * _SpotLightColor * _MaterialKs * specCoef;

                
                
                fragColor.rgb = ambient + pointDiffuse + pointSpecular + directionalDiffuse + directionalSpecular + spotDiffuse + spotSpecular;

                return fragColor;
            } 
            ENDCG
        }
    }
}
