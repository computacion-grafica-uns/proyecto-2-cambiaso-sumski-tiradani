Shader "Custom/TexturaProcedural"
{
	Properties
	{
		_Density("Density", Range(2,50)) = 30
        _PointLightColor ("Point Light Color", Color) = (1, 0, 0, 1)
        _SpotLightColor ("Spot Light Color", Color) = (1, 0, 0, 1)
        _DirectionalLightDirection_w ("Directional Light Direction (World)", Vector) = (0, 5, 0, 1)

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

			float _Density;

			v2f vert(float4 pos : POSITION, float2 uv : TEXCOORD0)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(pos);
				o.uv = uv * _Density;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float2 c = i.uv;
				c = floor(c) / 2;
				float checker = frac(c.x + c.y) * 2;

				fixed4 fragColor = fixed4(checker, 5.0, 4.0, 1.0);

				return fragColor;
			}
			ENDCG
		}
	}
}