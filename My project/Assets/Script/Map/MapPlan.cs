using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MapPlan : MonoBehaviour
{
    private GameObject baseRoom;
    private GameObject moveObj;

    void Start()
    {
        baseRoom = this.GetComponentInParent<Room>().baseRoom;
        moveObj = GameObject.Find("MoveObj");
    }


    void Update()
    {
        // UnityEngine.Debug.Log("Update");
    }

    void OnTriggerStay(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            if(baseRoom )
            {
                baseRoom.SetActive(true);
            }
            if(moveObj!=null)
            {
                moveObj.transform.position = new Vector3(this.GetComponentInParent<Transform>().position.x, moveObj.transform.position.y, this.GetComponentInParent<Transform>().position.z);
            }
        }
    }

    void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            baseRoom.SetActive(false);
        }
    }
}
