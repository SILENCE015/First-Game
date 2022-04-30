using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerAttackEvent : MonoBehaviour
{
    // Start is called before the first frame update
    public Transform[] pos;
    public Transform hitPos01,hitPos02,hitPos03;
    public Bullet obj;
    public Bullet hitObj;

    void Attack()
    {
        for (int i = 0; i < pos.Length; i++)
        {
            Bullet newBullet = Instantiate(obj, pos[i].position, pos[i].rotation) as Bullet;
        }
    }

    void Hit01()
    {
        Bullet newBullet = Instantiate(hitObj, hitPos01.position, hitPos01.rotation) as Bullet;
    }
    void Hit02()
    {
        Bullet newBullet = Instantiate(hitObj, hitPos02.position, hitPos02.rotation) as Bullet;
    }void Hit03()
    {
        Bullet newBullet = Instantiate(hitObj, hitPos03.position, hitPos03.rotation) as Bullet;
    }

}
