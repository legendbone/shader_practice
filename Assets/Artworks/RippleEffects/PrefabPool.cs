// #pragma warning disable 3001,3024
using System;
using System.Collections.Generic;
using UnityEngine;
using Object = UnityEngine.Object;

public sealed class PrefabPool : MonoBehaviour
{
    private static PrefabPool instance;
    public static PrefabPool Instance
    {
        get
        {
            if (instance == null)
            {
                var go = new GameObject("PrefabPool");
                instance = go.AddComponent<PrefabPool>();
            }

            return instance;
        }
    }


    public Transform PoolRoot;

    private readonly Dictionary<int, Queue<Component>> _prefab2Objects = new Dictionary<int, Queue<Component>>();

    private readonly Dictionary<Component, int> _object2Prefab = new Dictionary<Component, int>();


    private void Awake()
    {
        if (instance != null && instance != this)
        {
            Destroy(gameObject);
            return;
        }
        instance = this;

        PoolRoot = transform;
    }

    private Queue<Component> GetObjectsByPrefab(int hashCode)
    {
        if (_prefab2Objects.ContainsKey(hashCode))
            return _prefab2Objects[hashCode];

        var objects = new Queue<Component>();
        _prefab2Objects.Add(hashCode, objects);
        return objects;
    }

    public T Spawn<T>(T prefab, Vector3 position, Quaternion rotation) where T : Component
    {
        T obj = null;
        var objects = GetObjectsByPrefab(prefab.GetHashCode());
        if (objects.Count > 0)
        {
            obj = objects.Dequeue() as T;
            obj.transform.SetParent(null);
            obj.transform.localPosition = position;
            obj.transform.localRotation = rotation;
            obj.gameObject.SetActive(true);
        }
        else
        {
            obj = (T)Object.Instantiate(prefab, position, rotation);
        }

        _object2Prefab.Add(obj, prefab.GetHashCode());

        return obj;
    }

    public T Spawn<T>(T prefab, Vector3 position) where T : Component
    {
        return Spawn(prefab, position, Quaternion.identity);
    }

    public T Spawn<T>(T prefab) where T : Component
    {
        return Spawn(prefab, Vector3.zero, Quaternion.identity);
    }

    public void Recycle<T>(T obj) where T : Component
    {
        try
        {
            if (_object2Prefab.ContainsKey(obj))
            {
                var prefab = _object2Prefab[obj];
                var objects = GetObjectsByPrefab(prefab);
                objects.Enqueue(obj);
                _object2Prefab.Remove(obj);
                obj.transform.SetParent(PoolRoot);
                obj.gameObject.SetActive(false);
            }
            else
            {
                Object.Destroy(obj.gameObject);
            }
        }
        catch (Exception e)
        {
            Debug.LogError(obj.name + "Object Recycle|" + e.Message);
        }

    }

    public int Count<T>(T prefab) where T : Component
    {
        return _prefab2Objects.ContainsKey(prefab.GetHashCode()) ? _prefab2Objects[prefab.GetHashCode()].Count : 0;
    }


    /// <summary>
    /// 预缓存指定数量物体
    /// </summary>
    /// <typeparam name="T"></typeparam>
    /// <param name="prefab"></param>
    /// <param name="count"></param>
    public void Preload<T>(T prefab, int count) where T : Component
    {
        var list = new List<T>();
        for (int i = 0; i < count; i++)
        {
            var obj = Spawn(prefab);
            list.Add(obj);
        }

        foreach (var obj in list)
        {
            Recycle(obj);
        }
    }


    public void Clear()
    {
        try
        {
            foreach (var kvp in _prefab2Objects)
            {
                foreach (var component in kvp.Value)
                {
                    if (component != null && component.gameObject != null)
                    {
                        Object.DestroyImmediate(component.gameObject);
                    }
                }
            }

            _prefab2Objects.Clear();
            _object2Prefab.Clear();
        }
        catch (Exception e)
        {
            _prefab2Objects.Clear();
            _object2Prefab.Clear();
            Debug.LogError(e.Message);
        }
    }
}
