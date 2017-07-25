Shader "Unlit/DemoShader"
{
	Properties
	{
		_OutlineColor("Outline Color", Color) = (1, 1, 1, 1)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float viewDepth : TEXCOORD1;
				float4 screenPos : TEXCOORD0;
			};

			fixed4 _OutlineColor;
			sampler2D _DepthTexture;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.viewDepth = mul(UNITY_MATRIX_MV, v.vertex).z;
				o.screenPos = ComputeScreenPos(o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float2 screenUV = i.screenPos.xy / i.screenPos.w;
				float screenDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_DepthTexture, screenUV));

				float s = step(-i.viewDepth - 0.001, screenDepth);

				return _OutlineColor * s;
			}
			ENDCG
		}
	}
}
