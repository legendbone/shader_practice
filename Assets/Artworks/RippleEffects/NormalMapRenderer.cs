using System;
using UnityEngine;

public class NormalMapRenderer : MonoBehaviour
{
    public Camera RippleCamera;
    public RippleObject RippleRing;
    public RenderTexture TargetTexture;
    public Transform RippleRoot;
    public int PreloadRippleCount = 20;

    private float radioX;
    private float radioY;

    private void Start()
    {
        PrefabPool.Instance.Preload(RippleRing, PreloadRippleCount);

        if (RippleRoot == null)
        {
            RippleRoot = RippleCamera.transform;
        }
    }

    public RenderTexture GetRenderTexture()
    {
        var rt = TargetTexture;
        if (rt != null)
        {
            radioX = rt.width / Screen.width;
            radioY = rt.height / Screen.height;
        }
        else
        {
            radioX = radioY = 0.5f;
            rt = new RenderTexture((int)(Screen.width * radioX), (int)(Screen.height * radioY), 16);
            RippleCamera.targetTexture = rt;
        }

        return rt;
    }

    public void DrawRipple(int x, int y)
    {
        var x1 = x * radioX;
        var y1 = y * radioY;

        var ripple = PrefabPool.Instance.Spawn(RippleRing);//Instantiate(RippleRing);
        ripple.transform.SetParent(RippleRoot);
        ripple.transform.position = RippleCamera.ScreenToWorldPoint(new Vector3(x1, y1, 10));
        ripple.gameObject.SetActive(true);
    }

}