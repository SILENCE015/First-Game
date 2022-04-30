using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Shop : MonoBehaviour
{
    public Transform pos;
    public GameObject[] goods;
    GameObject currentGood;
    public int cost;
    bool isClose = false;

    private void Start()
    {
        SetGoods();
    }

    void SetGoods()
    {
        currentGood = goods[Random.Range(0, goods.Length)];
    }

    private void OnTriggerStay(Collider other)
    {
        if (other.CompareTag("Player") && !isClose)
        {
            GameManager.Instance.setUIMs("按F 花费" + cost + "购买" + currentGood.name, true);
            if (Input.GetKeyDown(KeyCode.F) && GameManager.Instance.playerStats.characterData.coins >= cost)
            {
                GameManager.Instance.playerStats.characterData.coins -= cost;
                Instantiate(currentGood, new Vector3(transform.position.x, transform.position.y + 5, transform.position.z + 10), transform.rotation);
                isClose = true;
            }
        }
    }

    private void OnTriggerExit(Collider other)
    {
        GameManager.Instance.setUIMs("按F 花费" + cost + "购买" + currentGood.name, false);
    }

}
