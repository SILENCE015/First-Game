using System.Diagnostics;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerMove : MonoBehaviour
{
    private CharacterController controller;
    private Animator anim;
    private AnimationClip[] clips;
    public CharacterStats characterStats;
    public float Speed;
    public float RotateSpeed;
    public float Gravity;
    private Vector3 Velocity = Vector3.zero;
    public Transform GroundCheck;
    public float CheckRadius;
    private bool IsGround;
    public LayerMask layerMask;
    private float lastAttackTime;
    private bool isDie;
    private bool isMove;
    private bool isIdle;
    public Transform[] pos;
    public Bullet obj;
    public float shotSpeed;
    public float attackSpeed;

    void Awake()
    {
        DontDestroyOnLoad(this);
        controller = transform.GetComponent<CharacterController>();
        anim = GetComponentInChildren<Animator>();
        clips = anim.runtimeAnimatorController.animationClips;
        characterStats = GetComponent<CharacterStats>();
    }

    void Start()
    {
        GameManager.Instance.RigisterPlayer(characterStats);
    }

    void Update()
    {
        isDie = characterStats.CurrentHealth == 0;
        if (isDie)
            GameManager.Instance.NotifyObservers();
        MoveContro();
        SwitchAnimation();
        AttackContro();
        AttackSpeed();
        if(Input.GetKeyDown(KeyCode.Escape))
            SceneController.Instance.StopGame();
    }

    private void MoveContro()
    {
        IsGround = Physics.CheckSphere(GroundCheck.position, CheckRadius, layerMask);
        if (IsGround && Velocity.y < 0)
        {
            Velocity.y = 0;
        }

        if (Input.anyKeyDown)
        {
            isMove = true;
            isIdle = false;
        }

        var horizontal = Input.GetAxisRaw("Horizontal");
        var vertical = Input.GetAxisRaw("Vertical");

        var direction = new Vector3(horizontal, 0, vertical).normalized;
        var move = direction * Speed * Time.fixedDeltaTime;
        controller.Move(move);

        Velocity.y += Gravity * Time.fixedDeltaTime;
        controller.Move(Velocity * Time.fixedDeltaTime);

        var playerScreenPoint = Camera.main.WorldToScreenPoint(transform.position);
        var point = Input.mousePosition - playerScreenPoint;
        var angle = Mathf.Atan2(point.x, point.y) * Mathf.Rad2Deg;

        transform.eulerAngles = new Vector3(transform.eulerAngles.x, angle, transform.eulerAngles.z);

        if (Input.GetKeyDown(KeyCode.LeftShift))
        {
            anim.SetTrigger("Dodge");
            var dodgeDirection = new Vector3(horizontal, 0, vertical).normalized;
            controller.Move(dodgeDirection * 10);
        }
    }

    private void AttackContro()
    {
        if (Input.GetMouseButtonDown(0))
        {
            anim.SetTrigger("Attack01");
        }
        if (Input.GetMouseButtonDown(1))
        {
            anim.SetBool("Attack02", true);
        }
        if (Input.GetMouseButtonUp(1))
        {
            anim.SetBool("Attack02", false);
        }
    }

    private void SwitchAnimation()
    {
        anim.SetFloat("Speed", Speed);
        anim.SetBool("Die", isDie);
        anim.SetBool("move", isMove);
        anim.SetBool("Idle", isIdle);
    }

    void AttackSpeed()
    {
        if (anim.GetCurrentAnimatorStateInfo(1).IsName("attack02"))
        {
            anim.speed = shotSpeed;
        }
        else if (anim.GetCurrentAnimatorStateInfo(1).IsName("attack01_1") || anim.GetCurrentAnimatorStateInfo(1).IsName("attack01_2") || anim.GetCurrentAnimatorStateInfo(1).IsName("attack01_3"))
        {
            anim.speed = attackSpeed;
        }
        else anim.speed = 1;
    }
}
