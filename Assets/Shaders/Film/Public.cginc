#ifndef __PUBLIC__
#define __PUBLIC__

#include "UnityCG.cginc"



struct a2f
{
    float4 vert : POSITION;
    float4 texcoord : TEXCOORD0;
};

struct v2f
{
    float4 pos : SV_POSITION;
    float2 uv : TEXCOORD0;
};


v2f vert(a2f v)
{
    v2f o;
    o.pos = UnityObjectToClipPos(v.vert);
    o.uv = v.texcoord.xy;
    return o;
}

#endif
