Shader "Custom/Output"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }

    CGINCLUDE

        #pragma target 3.0

        #include "UnityCG.cginc"
        #include "./Public.cginc"

        sampler2D _MainTex;

        float _Intensity;
        sampler2D _GrainTex;

        half3 frag(v2f i) : SV_Target
        {
            half3 color = tex2D(_MainTex, i.uv).rgb;
            color *= 0.5;

            float3 grain = tex2D(_GrainTex, i.uv).rgb;
            color += color * grain * _Intensity;
            return color;
        }

    ENDCG

    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM

                #pragma vertex vert
                #pragma fragment frag

            ENDCG
        }
    }
}
