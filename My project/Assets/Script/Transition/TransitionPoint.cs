using System.Net.Mime;
using System.Diagnostics;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TransitionPoint : MonoBehaviour
{
    [Header("Transition Info")]
    public string sceneName;
    public TransitionType transitionType;
    public TransitionDestination.DestinationTag destinationTag;
    private bool canTranss;
    public bool isLast = false;

    private void Start()
    {
        sceneName = this.name;
    }

    private void Update()
    {
        if(Input.GetKeyDown(KeyCode.F) && canTranss && !isLast)
        {
            UnityEngine.Debug.Log("传送");
            SceneController.Instance.TransitionToDestination(this);
            GameManager.Instance.setUIMs("按F进行传送", false);
        }
        if(Input.GetKeyDown(KeyCode.F) && canTranss && isLast)
        {
            Last();
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            GameManager.Instance.setUIMs("按F进行传送", true);
            canTranss = true;
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            canTranss = false;
            GameManager.Instance.setUIMs("按F进行传送", false);
        }
    }

    public void Last()
    {
        Application.Quit();
    }

    public enum TransitionType { SameScene, DifferentScene }
}
