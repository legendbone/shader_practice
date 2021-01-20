// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Zenjoy/RippleNormal"
{
	Properties
	{
		//水波纹法线贴图
		[HideInInspector]_BumpMap("Normalmap", 2D) = "bump" {}
		//法线扰动程度控制
		_BumpAmt("Distortion", Float) = 10
		//摄像机render texture
		[HideInInspector]_RefractionTex("RefractionTex",2D)="bump"{}
		//
		_Gloss ("_Gloss", Range(1.0, 10.0)) = 5.0
		_Dark ("_Dark", Range(0.0, 1.0)) = 0.5
		_LightDir("光方向(w是亮度)",Vector) = (0.5,0.5,0,500)


	}

	SubShader
	{
		Tags {"Queue"="Transparent" "IgnoreProjector" = "True" "RenderType"="Opaque" }
		///开启混合，关闭面片剔除和深度写入
		Blend SrcAlpha OneMinusSrcAlpha
		Lighting Off
		Cull Off
		ZWrite Off

		Pass
		{
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				fixed4 color:COLOR;
			};

			struct v2f
			{
				//float2 uvMain : TEXCOORD0;
				float2 uvBump:TEXCOORD0;
				//float4 scrPos:TEXCOORD2;
				float4 uvgrab:TEXCOORD1;
				float4 lightDir:TEXCOORD2;
				fixed4 color : COLOR;
				float4 vertex : POSITION;
			};
			sampler2D _RefractionTex;
			float4 _RefractionTex_TexelSize;
			
			half4 _Reflection;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpAmt;
			float _Dark;

			float4 _LightDir;
			half4 _LightColor;
			// float _Specular;
			float _Gloss;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;

				//根据渲染平台不同翻转renderte纹理坐标，垂直纹理坐标的惯例与 Direct3D、OpenGL 和 OpenGL ES 不同
				//当前的scale是根据分辨率wdith<height设置的，假如你的分辨率是wdith>height的话请对调下面的scale值才能保证正确效果
				#if UNITY_UV_START_AT_TOP
					float scale=-1.0;
				#else
					float scale=1.0;
				#endif
				//计算法线的采样的纹理坐标
				o.uvgrab.xy=(float2(o.vertex.x,o.vertex.y*(scale))+o.vertex.w)*0.5;
				o.uvgrab.zw=o.vertex.zw;
				//计算顶点摄像机空间的深度：距离裁剪平面的距离
				// COMPUTE_EYEDEPTH(o.uvgrab.z);
				o.uvBump=TRANSFORM_TEX(v.uv,_BumpMap);
				o.uvBump.y*=scale;
				half3 viewDir = half3(0, 0, 1);
				o.lightDir.xyz = normalize(_LightDir.xyz);
				o.lightDir.w = _LightDir.w;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				// fixed2 bump=UnpackNormal(tex2D(_BumpMap,fixed2( i.uvBump.x,i.uvBump.y))).rg;
				float3 normal = tex2D(_BumpMap,i.uvBump.xy).xyz;
				fixed2 bump=normal.xy * 2 - 1;
				normal = float3(bump.xy,normal.z);
				// return float4(0.5,0.5,1,1);
				// return float4(normal.xy,0,1);
				// return float4(normal.x,1,1,1);
				// return float4(normal,1);
				//模拟折射效果的坐标偏移
				float2 offset=bump*_BumpAmt*_RefractionTex_TexelSize.xy;
				// i.uvgrab.xy=offset*i.uvgrab.z+i.uvgrab.xy;
				i.uvgrab.xy=-0.05*offset+i.uvgrab.xy;


				// return fixed4(offset*10,0,1);
				// return fixed4(0,0,-i.uvgrab.z*2,1);
				// return fixed4(0,0,i.uvgrab.w,1);
				
				fixed3 refrCol=tex2D(_RefractionTex, i.uvgrab.xy).rgb*i.color.rgb;///i.uvgrab.w
				half4 c = half4(refrCol,i.color.a);
				
				float NdotL = dot(i.lightDir.xyz, normal);
				
				//fixed3 viewDir = normalize(fixed3(0,0,1));//normalize(_WorldSpaceCameraPos.xyz - mul(unity_WorldToObject, i.vertex).xyz);
				fixed specular = pow(saturate(NdotL), _Gloss) * i.lightDir.w;
				
				fixed diffuse = 1;
				if(bump.x!=0||bump.y!=0)
				{
					diffuse = lerp(_Dark, 1, NdotL + saturate(normal.z + 0.5));
				}
				c.rgb = c.rgb * diffuse + specular;

				return c;
				

				// fixed4 bump = tex2D(_BumpMap,i.uvBump.xy);
				// return bump;
			}
			ENDCG
		}
	}
	
}
