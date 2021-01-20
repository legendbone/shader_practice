using UnityEngine;

public class RippleWaterNormal : MonoBehaviour
{
    public RenderTexture NormalTex;
    public Material RippleMat;
    public NormalMapRenderer NormalMapRenderer;


    private void Start()
    {
        if (NormalMapRenderer == null)
        {
            Debug.LogError("NormalMapRenderer==null!");
            return;
        }

        NormalTex = NormalMapRenderer.GetRenderTexture();
        RippleMat.SetTexture("_BumpMap", NormalTex);
    }

    /// <summary>
    /// 获取当前摄像机的rendertexture
    /// </summary>
    /// <param name="src"></param>
    /// <param name="dest"></param>
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (RippleMat != null)
        {
            ///将摄像机获取的rendertexture赋值给shader
            RippleMat.SetTexture("_RefractionTex", src);
            Graphics.Blit(src, dest, RippleMat);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }

    public void OnClickScreen()
    {
#if UNITY_EDITOR
        Vector3 V3 = Input.mousePosition;
        AddRipplePoint((int)V3.x, (int)V3.y);
#else
        if (Input.touchCount > 0)
        {
            Vector3 V3 = Input.GetTouch(0).position;
            AddRipplePoint((int)V3.x, (int)V3.y);
        }
#endif

    }

    public void AddRipplePoint(int x, int y)
    {
        NormalMapRenderer.DrawRipple(x, y);
    }



}
