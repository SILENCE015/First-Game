using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class PlayerUI : MonoBehaviour
{
    Image healthSlider;
    Text healthText;
    Text speedText;
    Text powerText;
    Text defenseText;
    Text coinsText;
    CharacterStats playerStats;
    int MoveSpeedL, DamageL, ShotSpeedL;

    void Awake()
    {
        healthSlider = transform.GetChild(0).GetChild(0).GetComponent<Image>();
        healthText = transform.GetChild(0).GetChild(1).GetComponent<Text>();
        speedText = transform.GetChild(1).GetChild(0).GetComponent<Text>();
        powerText = transform.GetChild(1).GetChild(1).GetComponent<Text>();
        defenseText = transform.GetChild(1).GetChild(2).GetComponent<Text>();
        coinsText = transform.GetChild(1).GetChild(3).GetComponent<Text>();
    }

    private void Update()
    {
        UpdateHealth();
    }

    void UpdateHealth()
    {
        playerStats = GameManager.Instance.playerStats;
        float sliderPercent = (float)playerStats.CurrentHealth / playerStats.MaxHealth;
        healthSlider.fillAmount = sliderPercent;
        healthText.text = playerStats.CurrentHealth + " / " + playerStats.MaxHealth;
        coinsText.text = playerStats.Coins.ToString();
    }

    public void SetSpeedText(int n)
    {
        MoveSpeedL += n;
        speedText.text = MoveSpeedL.ToString();
    }
    public void SetPowerText(int n)
    {
        DamageL += n;
        powerText.text = DamageL.ToString();
    }
    public void SetdefenseText(int n)
    {
        ShotSpeedL += n;
        defenseText.text = ShotSpeedL.ToString();
    }
}
