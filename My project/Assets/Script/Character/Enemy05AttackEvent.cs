using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Enemy05AttackEvent : EnemyAttackEvent
{
    public Collider myCollider;
    private void Attack05()
    {
        if (myCollider.gameObject.GetComponent<EnemyController>().attackTarget != null)
        {
            myCollider.gameObject.transform.position = myCollider.gameObject.GetComponent<EnemyController>().attackTarget.transform.position;
        }
    }
}
