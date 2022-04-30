using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyHitEvent : MonoBehaviour
{
    public Transform ItemPos;
    public EnemyController myController;

    [Header("Iteams")]
    public GameObject[] iteams;
    void Hit()
    {
        if (myController.attackTarget != null)
        {
            var targetStats = myController.attackTarget.GetComponent<CharacterStats>();
            targetStats.TakeDamage(myController.characterStats.CurrentDamage());
        }
    }

    public void InstantiateIteams()
    {
        if (Random.Range(0f, 1f) <= 0.8f)
        {
            UnityEngine.Debug.Log("掉落");
            GameObject newiteam = Instantiate(iteams[Random.Range(0, iteams.Length)], new Vector3(ItemPos.position.x, ItemPos.position.y, ItemPos.position.z), iteams[Random.Range(0, iteams.Length)].transform.rotation);
            newiteam.transform.parent = GameObject.FindGameObjectsWithTag("Items")[0].transform;
        }
    }
}
