using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bullet : MonoBehaviour
{

    public LayerMask collisionMask;
    public String mask;

    public float speed = 50;
    public int damage = 10;
    public float lifeTime = 2f;
    float skinWidth = 0.1f;

    void Start()
    {
        Destroy(gameObject, lifeTime);
        // characterStats = GetComponent<CharacterStats>();

        Collider[] initialCollisions = Physics.OverlapSphere(transform.position, 0.1f, collisionMask);
        if (initialCollisions.Length > 0)
        {
            OnHitObject(initialCollisions[0], transform.position);
        }
    }

    public void SetSpeed(float newSpeed)
    {
        this.speed = newSpeed;
    }

    void Update()
    {
        float moveDistance = speed * Time.deltaTime;    //射击距离

        CheckCollisions(moveDistance);

        transform.Translate(Vector3.forward * moveDistance);
        //子弹消失
    }

    void CheckCollisions(float moveDistance)
    {
        Ray ray = new Ray(transform.position, transform.forward);
        RaycastHit hit;

        if (Physics.Raycast(ray, out hit, moveDistance + skinWidth, collisionMask, QueryTriggerInteraction.Collide))
        {
            OnHitObject(hit.collider, hit.point);
        }

    }

    void OnHitObject(Collider c, Vector3 hitPoint)
    {
        // UnityEngine.Debug.Log(c.name);
        var target = c.GetComponent<CharacterStats>();
        target.TakeDamage(damage);
        GameObject.Destroy(gameObject);
    }

    void OnTriggerEnter(Collider c)
    {
        if (c.CompareTag(mask))
        {
            UnityEngine.Debug.Log(c.name);
            var target = c.GetComponent<CharacterStats>();
            target.TakeDamage(damage);
            GameObject.Destroy(gameObject, 0.5f);
        }
    }
}
