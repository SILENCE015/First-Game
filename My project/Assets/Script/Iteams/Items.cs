using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Items : MonoBehaviour
{
    public DateType dateType;
    public int changeNumber;
    public Bullet weapon;
    CharacterStats playerStats;

    private void Update()
    {
        playerStats = GameManager.Instance.playerStats;
        transform.eulerAngles = new Vector3(transform.eulerAngles.x, Time.fixedTime * Mathf.PI * 10, transform.eulerAngles.z);
    }

    private void OnTriggerStay(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            changeDate(dateType, changeNumber);
            UnityEngine.Debug.Log("拾取");
        }
    }

    void changeDate(DateType dateType, int n)
    {
        switch (dateType)
        {
            case DateType.MaxHealth:
                playerStats.MaxHealth += n;
                playerStats.CurrentHealth += n;
                GameManager.Instance.setUIMs("最大生命值+" + n, true);
                Destroy(this.gameObject);
                break;
            case DateType.Health:
                if (playerStats.CurrentHealth + n >= playerStats.MaxHealth)
                {
                    playerStats.CurrentHealth = playerStats.MaxHealth;
                }
                else
                {
                    playerStats.CurrentHealth += n;
                }
                Destroy(this.gameObject);
                break;
            case DateType.MoveSpeed:
                playerStats.GetComponent<PlayerMove>().Speed += n;
                GameManager.Instance.setUIMs("移动速度+1", true);
                GameManager.Instance.MainUI.transform.GetChild(0).GetComponent<PlayerUI>().SetSpeedText(1);
                Destroy(this.gameObject);
                break;
            case DateType.Damage:
                playerStats.GetComponentInChildren<PlayerAttackEvent>().obj.damage += n;
                GameManager.Instance.setUIMs("伤害等级+1", true);
                GameManager.Instance.MainUI.transform.GetChild(0).GetComponent<PlayerUI>().SetPowerText(1);
                Destroy(this.gameObject);
                break;
            case DateType.Coins:
                UnityEngine.Debug.Log("前" + playerStats.Coins);
                playerStats.Coins += n;
                GameManager.Instance.setUIMs("拾取了 " + n + "个金币", true);
                Destroy(this.gameObject);
                break;
            case DateType.Weapon:
                GameManager.Instance.setUIMs("按F 拾取 " + weapon.name, true);
                if (Input.GetKeyDown(KeyCode.F))
                {
                    playerStats.gameObject.GetComponentInChildren<PlayerAttackEvent>().obj = weapon;
                    Debug.Log(playerStats.gameObject.GetComponentInChildren<PlayerAttackEvent>().obj);
                    GameManager.Instance.setUIMs("拾取了 " + weapon.name, true);
                    Destroy(this.gameObject);
                }
                break;
            case DateType.ShotSpeed:
                playerStats.GetComponent<PlayerMove>().shotSpeed += n;
                GameManager.Instance.setUIMs("射击速度+1", true);
                GameManager.Instance.MainUI.transform.GetChild(0).GetComponent<PlayerUI>().SetdefenseText(1);
                Destroy(this.gameObject);
                break;
        }
    }

    public enum DateType { MaxHealth, Health, MoveSpeed, Coins, Weapon, Damage, ShotSpeed }
}
