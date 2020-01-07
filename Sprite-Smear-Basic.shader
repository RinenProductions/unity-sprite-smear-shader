
Shader "Sprites/Sprite-Smear-Basic"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		_Color("Tint", Color) = (1,1,1,1)
		_FlashColor("Flash Tint", Color) = (0,0,0,0) 
		_PixelSize("Pixel Size (1/PPU)", Float) = 0
		_Position("Position", Vector) = (0, 0, 0, 0)
		_SmearDirection("Smear Direction", Vector) = (0, 0, 0, 0)
		[MaterialToggle] PixelSnap("Pixel snap", Float) = 0
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
			"PreviewType" = "Plane"
			"CanUseSpriteAtlas" = "True"
		}

		Cull Off
		Lighting Off
		ZWrite Off
		Blend One OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile _ PIXELSNAP_ON
			#include "UnityCG.cginc"

			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color : COLOR;
				float2 texcoord  : TEXCOORD0;
			};

			fixed4 _Color;
			fixed4 _FlashColor;

			float _PixelSize;
			fixed4 _Position;
			fixed4 _SmearDirection;

			v2f vert(appdata_t IN)
			{
				v2f OUT;
				OUT.vertex = mul(unity_ObjectToWorld, IN.vertex);
				OUT.texcoord = IN.texcoord;
				OUT.color = IN.color * _Color;
				OUT.color += _FlashColor;

				fixed2 direction = _SmearDirection ;
				fixed2 vertexOffset = OUT.vertex.xy - _Position.xy;

				float dotProduct = dot(normalize(direction), normalize(vertexOffset) * 2);
				direction *= _PixelSize;
				direction *= -clamp(dotProduct, -1, 0);
				OUT.vertex.xy -= direction.xy;
				OUT.vertex = mul(unity_WorldToObject, OUT.vertex);
				OUT.vertex = UnityObjectToClipPos(OUT.vertex);

				#ifdef PIXELSNAP_ON
				OUT.vertex = UnityPixelSnap(OUT.vertex);
				#endif
				return OUT;
			}

			sampler2D _MainTex;
			sampler2D _AlphaTex;
			float _AlphaSplitEnabled;

			fixed4 SampleSpriteTexture(float2 uv)
			{
				fixed4 color = tex2D(_MainTex, uv);
				#if UNITY_TEXTURE_ALPHASPLIT_ALLOWED
				if (_AlphaSplitEnabled)
					color.a = tex2D(_AlphaTex, uv).r;
				#endif 
				return color;
			}

			fixed4 frag(v2f IN) : SV_Target
			{
				fixed4 c = SampleSpriteTexture(IN.texcoord) * IN.color;
				c.rgb *= c.a;
				return c;
			}
			ENDCG
		}
	}
}