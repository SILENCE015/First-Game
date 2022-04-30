using System;
using System.Diagnostics.Contracts;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class EnemyUI : MonoBehaviour
{
    public GameObject EnemyHealthUI;
    public Transform UIPoint;

    Image health;
    Transform UIbar;
    Transform cam;

    CharacterStats currentStats;

    void Awake()
    {
        currentStats = GetComponent<CharacterStats>();
        currentStats.UpdateHealth += UpdateHealth;

        cam = Camera.main.transform;

        foreach (Canvas canvas in FindObjectsOfType<Canvas>())
        {
            if (canvas.renderMode == RenderMode.WorldSpace)
            {
                UIbar = Instantiate(EnemyHealthUI, canvas.transform).transform;
                health = UIbar.GetChild(0).GetComponent<Image>();
                UIbar.gameObject.SetActive(true);
            }
        }
    }

    // void OnEnable()
    // {
    //     cam = Camera.main.transform;

    //     foreach (Canvas canvas in FindObjectsOfType<Canvas>())
    //     {
    //         if (canvas.renderMode == RenderMode.WorldSpace)
    //         {
    //             UIbar = Instantiate(EnemyHealthUI, canvas.transform).transform;
    //             health = UIbar.GetChild(0).GetComponent<Image>();
    //             UIbar.gameObject.SetActive(true);
    //         }
    //     }
    // }

    private void UpdateHealth(int currentHealth, int maxHealth)
    {
        if (currentHealth <= 0)
            Destroy(UIbar.gameObject);

        float sliderPercent = (float)currentHealth / maxHealth;
        health.fillAmount = sliderPercent;
    }

    void Update()
    {
        if (UIbar != null)
        {
            UIbar.position = UIPoint.position;
            UIbar.forward = cam.forward;
        }
    }
}
