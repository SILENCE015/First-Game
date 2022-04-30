using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyGenerator : MonoBehaviour
{
    public GameObject[] Enemys;
    public List<GameObject> InEnemys = new List<GameObject>();
    public CharacterData_SO[] EnemyDatas;
    public AttackData_SO[] attackDatas;
    public List<EnemyController> TREnemys = new List<EnemyController>();
    public int GRange;
    private bool isClear = false;

    void Awake()
    {
        if (!isClear)
        {
            EnemyGenerate();
        }
    }
    void Update()
    {
        if (transform.childCount == 0)
        {
            isClear = true;
            // GetComponentInParent<Room>
            GetComponentInParent<Room>().isClear = isClear;
            GetComponentInParent<Room>().doors.SetActive(true);
        }
    }

    private void EnemyGenerate()
    {
        for (int i = 0; i < 4; i++)
        {
            InEnemys.Add(Enemys[Random.Range(0, Enemys.Length)]);
        }
        for (int i = 0; i < 4; i++)
        {
            float randomX = Random.Range(-GRange, GRange);
            float randomZ = Random.Range(-GRange, GRange);
            Vector3 randomPoint = new Vector3(transform.position.x + randomX, 2, transform.position.z + randomZ);
            GameObject newEnemy = Instantiate(InEnemys[i], randomPoint, this.transform.rotation);
            TREnemys.Add(newEnemy.GetComponent<EnemyController>());
            newEnemy.transform.parent = transform;
            newEnemy.GetComponent<CharacterStats>().templateData = EnemyDatas[GameManager.Instance.GameLevel];
        }
    }
}
