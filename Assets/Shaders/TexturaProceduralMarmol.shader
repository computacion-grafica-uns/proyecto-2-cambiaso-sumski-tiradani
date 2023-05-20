Shader "Custom/TexturaProceduralMarmol"
{
	Properties
	{
		_Density("Density", Range(2,50)) = 30
		_Resolution("Resolution", Vector) = (10,10,0,0)
		
		//Iluminación
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
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
                float4 position_w : TEXCOORD2;
                float3 normal_w : TEXCOORD1;
			};

			struct vertexData {
                float4 position : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

			float _Density;
			float2 _Resolution;

			//Luces
            float4 _AmbientLight;
            float4 _MaterialKa;
            float4 _MaterialKs;
            float _Material_n;
            
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

			float random (float2 st) {
				return frac(sin(dot(st.xy,float2(12.9898,78.233)))*43758.5453123);
			}

			float noise (float2 st) {
				float2 i = floor(st);
				float2 f = frac(st);

				float a = random(i);
				float b = random(i + float2(1.0, 0.0));
				float c = random(i + float2(0.0, 1.0));
				float d = random(i + float2(1.0, 1.0));

				float2 u = f * f * (3.0 - 2.0 * f);

				return lerp(a, b, u.x) +
						(c - a)* u.y * (1.0 - u.x) +
						(d - b) * u.x * u.y;
			}

			#define OCTAVES 6
			float fbm (float2 st) {
				float value = 0.0;
				float amplitud = .5;
				float frequency = 0.;

				for (int i = 0; i < OCTAVES; i++) {
					value += amplitud * noise(st);
					st *= 2.;
					amplitud *= .5;
				}
				return value;
			}

			v2f vert(vertexData v, float4 pos : POSITION, float2 uv : TEXCOORD0)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(pos);
				o.normal_w = UnityObjectToWorldNormal(v.normal);
				o.position_w = mul(unity_ObjectToWorld, v.position);
				o.uv = uv;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				//Procedural
				float2 st = (i.uv*_Density) / _Resolution.xy;
				st.x *= _Resolution.x / _Resolution.y;

				float v = smoothstep(0.5, 0.390, fbm(st * 10.0));

				float3 _MaterialKd = float4(v,0.7*v,2.188*v, 1.0);

				//Iluminacion
				float3 ambient = _AmbientLight * _MaterialKa;
				fixed4 fragColor = 0;
				float3 N = normalize(i.normal_w);

				// Point
                float3 point_L = normalize(_PointLightPosition_w.xyz - i.position_w.xyz);

                float3 pointDiffuse = _PointLightIntensity * _PointLightColor * _MaterialKd * max(0, dot(N,point_L));

                float3 V = normalize(_WorldSpaceCameraPos.xyz - i.position_w.xyz);
                float3 H = normalize(point_L + V); 

                float3 pointSpecular = _PointLightIntensity * _PointLightColor * _MaterialKs * pow(max(0,dot(H,N)),max(1,_Material_n));

                // Directional

                float3 directional_L = normalize(-(_DirectionalLightDirection_w.xyz));

                float3 directionalDiffuse = _MaterialKd * _DirectionalLightIntensity * _DirectionalLightColor * max(0, dot(N,directional_L));
                
                V = normalize(_WorldSpaceCameraPos.xyz - i.position_w.xyz);
                H = normalize(directional_L + V);

                float3 directionalSpecular = _DirectionalLightIntensity * _DirectionalLightColor * _MaterialKs * pow(max(0,dot(H,N)),max(1,_Material_n));

                // Spot

                float diffCoef = 0;
                float specCoef = 0;

                float3 spot_L = normalize(_SpotLightPosition_w.xyz - i.position_w.xyz);

                float cosenoDireccion = dot(-(_SpotLightDirection_w), spot_L);

                if (cosenoDireccion >= cos(radians(_SpotAperture)) ){
                    diffCoef = max(0,dot(N,spot_L));
                }

                float3 spotDiffuse = _SpotLightIntensity * _SpotLightColor * _MaterialKd * (diffCoef);

                V = normalize(_WorldSpaceCameraPos.xyz - i.position_w.xyz);
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