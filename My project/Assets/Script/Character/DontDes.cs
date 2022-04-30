using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DontDes : MonoBehaviour
{
    protected void Awake()
    {
        DontDestroyOnLoad(this);
    }
}
