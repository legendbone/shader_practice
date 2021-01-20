Shader "Zenjoy/DistortSelf"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _Noise ("Noise", 2D) = "white" {}
        _distortFactorTime("FactorTime",Range(0,5)) = 0.5
        _distortFactor("factor",Range(0.01,1)) = 0

        _Color("Color",Color) = (1,1,1,1)
        _XSpeed("XSpeed",Range(-1,1)) = 0
        _YSpeed("YSpeed",Range(-1,1)) = 0
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off Lighting Off ZWrite Off
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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _Noise;
            fixed _distortFactorTime;
            fixed _distortFactor;
            fixed4 _Color;
            float _XSpeed;
            float _YSpeed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv += float2(_XSpeed, _YSpeed)*_Time.y;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 bias = tex2D(_Noise, i.uv+_Time.xy*_distortFactorTime);
                half4 color = tex2D(_MainTex, i.uv+bias.xy*_distortFactor);
                return color*_Color;
            }
            ENDCG
        }
    }
}