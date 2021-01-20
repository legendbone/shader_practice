using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class ClickEmit : MonoBehaviour
{
    public UnityEvent OnTouch;
    public float Interval = 0.1f;

    private float lastTime = 0;

    // Update is called once per frame
    void Update()
    {
        if (Input.GetMouseButton(0))
        {
            if (Time.time - lastTime > Interval)
            {
                OnTouch.Invoke();
                lastTime = Time.time;
            }
        }
    }
}
