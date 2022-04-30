using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyAttackEvent : MonoBehaviour
{
    public Transform[] pos;
    public Transform ItemPos;
    public Bullet obj;

    [Header("Iteams")]
    public GameObject[] iteams = null;
    void Attack()
    {
        for (int i = 0; i < pos.Length; i++)
        {
            Bullet newBullet = Instantiate(obj, pos[i].position, pos[i].rotation) as Bullet;
        }
    }

    public void InstantiateIteams()
    {
        if (Random.Range(0f, 1f) <= 0.8f)
        {
            GameObject newIteam = Instantiate(iteams[Random.Range(0, iteams.Length)], new Vector3(ItemPos.position.x, ItemPos.position.y, ItemPos.position.z), iteams[Random.Range(0, iteams.Length)].transform.rotation);
            newIteam.transform.parent = GameObject.FindGameObjectsWithTag("Items")[0].transform;
        }
    }
}
