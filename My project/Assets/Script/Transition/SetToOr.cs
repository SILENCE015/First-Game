using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SetToOr : MonoBehaviour
{
    public Transform roomPos;

    private void OnTriggerStay(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            Debug.Log("yes");
            GameManager.Instance.playerStats.gameObject.transform.SetPositionAndRotation(new Vector3(roomPos.position.x, roomPos.position.y + 15, roomPos.position.z), transform.rotation);
        }
    }
}
