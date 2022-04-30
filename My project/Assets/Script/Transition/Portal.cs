using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Portal : MonoBehaviour
{
    public enum Door { Up, Down, Left, Right };
    public Door door;
    public float Length;
    private bool canTrans;
    GameObject player;

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.F) && canTrans)
        {
            SceneController.Instance.NextDoor(door, Length, this.transform.position);
            GameManager.Instance.setUIMs("按F进行传送", false);
            canTrans = false;
        }
    }

    private void OnTriggerStay(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            Debug.Log("在门里");
            GameManager.Instance.setUIMs("按F进行传送", true);
            canTrans = true;
        }
    }
}
