using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DistortEffect : MonoBehaviour
{
    public Material RenderMaterial;


    /// <summary>
    /// 获取当前摄像机的rendertexture
    /// </summary>
    /// <param name="src"></param>
    /// <param name="dest"></param>
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (RenderMaterial != null)
        {
            // RenderMaterial.SetTexture("_MainTex", src);
            Graphics.Blit(src, dest, RenderMaterial);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
