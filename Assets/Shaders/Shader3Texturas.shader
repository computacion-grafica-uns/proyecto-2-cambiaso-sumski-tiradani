Shader "Custom/ShaderMultitextura"
{
    Properties
    {
        // we have removed support for texture tiling/offset,
        // so make them not be displayed in material inspector
        [NoScaleOffset] _DayTex ("Texture", 2D) = "white" {}
        [NoScaleOffset] _NightTex ("Texture", 2D) = "white" {}
        [NoScaleOffset] _CloudsTex ("Texture", 2D) = "white" {}

        _PointLightColor ("Point Light Color", Color) = (1, 0, 0, 1)
        _PointLightPosition_w ("Point Light Position (World)", Vector) = (0, 5, 0, 1)

    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vertexShader
            #pragma fragment fragmentShader
            #include "UnityCG.cginc"

            float4 _PointLightPosition_w;
            float4 _PointLightColor;

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

           
            
            // texture we will sample
            sampler2D _DayTex;
            sampler2D _NightTex;
            sampler2D _CloudsTex;

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

                // Textura
                fixed4 day = tex2D(_DayTex, f.uv);
                fixed4 night = tex2D(_NightTex, f.uv);
                fixed4 clouds = tex2D(_CloudsTex, f.uv);

                // Point
                float3 L = normalize(_PointLightPosition_w.xyz - f.position_w.xyz);
                diffCoef = max(0, dot(N,L));
                float mixFactor = smoothstep(-0.3, 0.3, dot(N,L));
				float3 mixedColor = lerp(night, day, mixFactor) ;

                if(dot(N,L) < -0.3){
                    pointColor.rgb = night.rgb * 0.1 * _PointLightColor;
                }
                else if(dot(N,L) > 0.3)
                    {
                        pointColor.rgb = day.rgb * diffCoef * _PointLightColor;
                    }
                    else    
                    {
                        pointColor.rgb = mixedColor * _PointLightColor * (max(0.1,diffCoef));
                    }
                
                    
                pointColor.rgb += clouds * 0.05;

                return pointColor;
            } 
            ENDCG
        }
    }
}
