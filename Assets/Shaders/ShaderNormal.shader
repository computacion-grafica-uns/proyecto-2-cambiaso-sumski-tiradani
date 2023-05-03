Shader "Custom/ShaderNormal"
{
    /*Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }*/
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass{
            CGPROGRAM
            #pragma vertex vertexShader
            #pragma fragment fragmentShader
            #include "UnityCG.cginc"

            struct vertexData
            {
                float4 position : POSITION; // Object space
                float3 normal : NORMAL; // Object space
            };

            struct v2f
            {
                float4 position : SV_POSITION; // Clipping space
                float3 normal_o : TEXTCOORD0; // Object space
            };

            v2f vertexShader(vertexData v){
                v2f output;
                output.position = UnityObjectToClipPos(v.position);
                output.normal_o = v.normal;
                return output;
            }

            fixed4 fragmentShader (v2f f) : SV_Target{
                fixed4 fragColor = 0;
                fragColor.rgb = f.normal_o * 0.5 + 0.5;
                return fragColor;
            }
            ENDCG
        }
    }   
}
