using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RippleObject : MonoBehaviour
{
    public float Duration = 5;

    private void OnEnable()
    {
        StartCoroutine(DelayRecyle());
    }

    private void OnDisable()
    {
        // StopAllCoroutines();
    }

    private IEnumerator DelayRecyle()
    {
        yield return new WaitForSeconds(Duration);
        PrefabPool.Instance.Recycle(this);
    }
}
