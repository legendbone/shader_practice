Shader "Zenjoy/TexMove"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}
        // _NoiseTex("Noise Texture", 2D) = "white" {}
        _XSpeed("X Speed",Float) = 0
        _YSpeed("Y SPeed",Float) = 0
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
				fixed4 color:COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                // float2 uvNo : TEXCOORD1;
                float4 vertex : SV_POSITION;
				fixed4 color:COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            // sampler2D _NoiseTex;
            // float4 _NoiseTex_ST;

            float _XSpeed;
            float _YSpeed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;
                // o.uvNo = TRANSFORM_TEX(v.uv, _NoiseTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // half4 bias = tex2D(_NoiseTex, i.uvNo+_Time.xy*_XSpeed);
                // bias = half4(bias.rgb,0.5);
                // half4 color = tex2D(_MainTex, i.uv);
                // return color*bias;
                float2 uv = float2(i.uv.x+_Time.x*_XSpeed,i.uv.y+_Time.y*_YSpeed);
                half4 color = tex2D(_MainTex,uv);
                return i.color*color;
            }

            ENDCG
        }
    }
}