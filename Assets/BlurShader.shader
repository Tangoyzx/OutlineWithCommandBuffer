Shader "Unlit/BlurShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		CGINCLUDE

		#include "UnityCG.cginc"

		struct appdata
		{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
		};

		struct v2f
		{
			float2 uv : TEXCOORD0;
			float4 uv12 : TEXCOORD1;
			float4 uv34 : TEXCOORD2;
			float4 vertex : SV_POSITION;
		};

		sampler2D _MainTex;
		float4 _MainTex_TexelSize;

		inline fixed4 blurColor(v2f i) {
			fixed4 c0 = tex2D(_MainTex, i.uv);
			fixed4 c1 = tex2D(_MainTex, i.uv12.xy);
			fixed4 c2 = tex2D(_MainTex, i.uv12.zw);
			fixed4 c3 = tex2D(_MainTex, i.uv34.xy);
			fixed4 c4 = tex2D(_MainTex, i.uv34.zw);

			return max(max(max(c0, c1), max(c2, c3)), c4);
		}

		ENDCG

		// Pass 0
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.uv12.xy = v.uv + float2(_MainTex_TexelSize.x, 0);
				o.uv12.zw = v.uv + float2(-_MainTex_TexelSize.x, 0);
				o.uv34.xy = v.uv + float2(_MainTex_TexelSize.x * 2, 0);
				o.uv34.zw = v.uv + float2(-_MainTex_TexelSize.x * 2, 0);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				return blurColor(i);
			}
			ENDCG
		}

		// Pass 1
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.uv12.xy = v.uv + float2(0, _MainTex_TexelSize.y);
				o.uv12.zw = v.uv + float2(0, -_MainTex_TexelSize.y);
				o.uv34.xy = v.uv + float2(0, _MainTex_TexelSize.y * 2);
				o.uv34.zw = v.uv + float2(0, -_MainTex_TexelSize.y * 2);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				return blurColor(i);
			}
			ENDCG
		}
	}
}
