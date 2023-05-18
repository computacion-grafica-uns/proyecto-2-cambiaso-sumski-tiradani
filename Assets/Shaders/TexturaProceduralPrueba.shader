Shader "Custom/TexturaProceduralPrueba"
{
	Properties
	{
        _Factor1 ("Factor 1", float) = 1
        _Factor2 ("Factor 2", float) = 1
        _Factor3 ("Factor 3", float) = 1
        
		_ku("ku", Range(2,500)) = 30
		_kv("kv", Range(2,500)) = 30
		_Density("Density", Range(2,500)) = 30
        _Color("Color", Color) = (1,1,1,1)
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
			};

            float _Factor1;
            float _Factor2;
            float _Factor3;
            float4 _Color;

			float _Density;
			float _ku;
			float _kv;

			float noise(half2 uv)
            {
                return frac(sin(dot(uv, float2(_Factor1, _Factor2))) * _Factor3);
            }

			float marble(float u, float v)
			{
				float f = 0.0;
				f = noise(float2(u, v));
				return sin(_ku * u + _kv * v+ _Density*f);
			}

			v2f vert(float4 pos : POSITION, float2 uv : TEXCOORD0)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(pos);
				o.uv = uv;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 fragColor = 0;
				float c=marble(i.uv.x,i.uv.y);
				fragColor = fixed4(c*_Color.r,_Color.g*c,c*_Color.b, 1.0);

				return fragColor;
			}
			ENDCG
		}
	}
}