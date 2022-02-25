Shader "Custom/Grain"
{
    CGINCLUDE

        #pragma exclude_renderers d3d11_9x
        #pragma target 3.0
        #include "UnityCG.cginc"
        #include "./Public.cginc"

        //从外部获取随机数，让画面达到随机变换的效果
        float _Random;

        //噪点像素值生成方法
        float Noise(float2 n, float x)
        {
            n += x;
            return frac(sin(dot(n.xy, float2(12.9898, 78.233))) * 43758.5453);
        }

        //对每一个像素进行卷积操作，取其周围及自身的像素值生成噪点，再以一定权重相加
        float Step1(float2 uv, float n)
        {
            float a = 1.0, b = 2.0, c = -12.0, t = 1.0;   
            return (1.0 / (a * 4.0 + b * 4.0 + abs(c))) * (
            Noise(uv + float2(-1.0,-1.0) * t, n) * a +
            Noise(uv + float2( 0.0,-1.0) * t, n) * b +
            Noise(uv + float2( 1.0,-1.0) * t, n) * a +
            Noise(uv + float2(-1.0, 0.0) * t, n) * b +
            Noise(uv + float2( 0.0, 0.0) * t, n) * c +
            Noise(uv + float2( 1.0, 0.0) * t, n) * b +
            Noise(uv + float2(-1.0, 1.0) * t, n) * a +
            Noise(uv + float2( 0.0, 1.0) * t, n) * b +
            Noise(uv + float2( 1.0, 1.0) * t, n) * a +
            0.0);
        }

        //再对每一个像素进行卷积操作，取的是上面Step1的结果，这样可以让噪点分布更加均匀
        float Step2(float2 uv, float n)
        {
            float a = 1.0, b = 2.0, c = 4.0, t = 1.0;   
            return (1.0 / (a * 4.0 + b * 4.0 + abs(c))) * (
            Step1(uv + float2(-1.0,-1.0) * t, n) * a +
            Step1(uv + float2( 0.0,-1.0) * t, n) * b +
            Step1(uv + float2( 1.0,-1.0) * t, n) * a +
            Step1(uv + float2(-1.0, 0.0) * t, n) * b +
            Step1(uv + float2( 0.0, 0.0) * t, n) * c +
            Step1(uv + float2( 1.0, 0.0) * t, n) * b +
            Step1(uv + float2(-1.0, 1.0) * t, n) * a +
            Step1(uv + float2( 0.0, 1.0) * t, n) * b +
            Step1(uv + float2( 1.0, 1.0) * t, n) * a +
            0.0);
        }

        //对三个颜色通道赋值，值来自Step2，这里会将外部传入的随机数传到Step2中，让画面达到随机变换的效果
        float3 Step3(float2 uv)
        {
            float a = Step2(uv, 0.07 * frac(_Random));
            float b = Step2(uv, 0.11 * frac(_Random));
            float c = Step2(uv, 0.13 * frac(_Random));
            return float3(a, b, c);
        }

        float3 frag(v2f i) : SV_Target
        {
            return Step3(i.uv);
        }

    ENDCG

    SubShader
    {
        //由于是屏幕渲染，所以剔除和深度都可以关
        Cull Back ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM

                #pragma vertex vert
                #pragma fragment frag

            ENDCG
        }

    }
}
