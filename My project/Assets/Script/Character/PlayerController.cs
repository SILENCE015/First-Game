using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class PlayerController : MonoBehaviour
{
    private CharacterController controller;
    private Animator anim;
    private CharacterStats characterStats;
    private float lastAttackTime;
    private bool isDie;

    [Header("Move Setting")]
    public float Speed;
    public float RotateSpeed;
    public float Gravity;
    private Vector3 Velocity = Vector3.zero;
    public Transform GroundCheck;
    public float CheckRadius;
    private bool IsGround;
    public LayerMask layerMask;


    void Awake()
    {
        anim = GetComponent<Animator>();
        characterStats = GetComponent<CharacterStats>();
    }

    void Start()
    {
        GameManager.Instance.RigisterPlayer(characterStats);
        controller = transform.GetComponent<CharacterController>();
    }

    void Update()
    {
        MoveContro();
        isDie = characterStats.CurrentHealth == 0;

        if (isDie)
            GameManager.Instance.NotifyObservers();

        SwitchAnimation();

        lastAttackTime -= Time.deltaTime;
    }

    private void SwitchAnimation()
    {
        anim.SetBool("Die", isDie);
    }

    private void MoveContro()
    {
        IsGround = Physics.CheckSphere(GroundCheck.position, CheckRadius, layerMask);
        if (IsGround && Velocity.y < 0)
        {
            Velocity.y = 0;
        }

        var horizontal = Input.GetAxis("Horizontal");
        var vertical = Input.GetAxis("Vertical");

        var direction = new Vector3(horizontal, 0, vertical).normalized;
        var move = direction * Speed * Time.fixedDeltaTime;
        controller.Move(move);

        Velocity.y += Gravity * Time.fixedDeltaTime;
        controller.Move(Velocity * Time.fixedDeltaTime);

        var playerScreenPoint = Camera.main.WorldToScreenPoint(transform.position);
        var point = Input.mousePosition - playerScreenPoint;
        var angle = Mathf.Atan2(point.x, point.y) * Mathf.Rad2Deg;

        transform.eulerAngles = new Vector3(transform.eulerAngles.x, angle, transform.eulerAngles.z);
    }
}
