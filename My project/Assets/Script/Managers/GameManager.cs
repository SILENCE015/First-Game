using System.Net.Mime;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using Cinemachine;

public class GameManager : Singleton<GameManager>
{
    public CharacterStats playerStats;
    public CinemachineVirtualCamera followCamera;
    public Camera MainCamera;
    public int GameLevel;
    public List<GameObject> items;
    public Canvas MainUI;
    public GameObject[] CantDestoryByLoad;

    List<IEndGameObserve> endGameObserves = new List<IEndGameObserve>();

    protected override void Awake()
    {
        base.Awake();
        DontDestroyOnLoad(this);
        MainCamera = GameObject.FindGameObjectsWithTag("MainCamera")[0].GetComponent<Camera>();
    }
    public void RigisterPlayer(CharacterStats player)
    {
        playerStats = player;
        followCamera = FindObjectOfType<CinemachineVirtualCamera>();
        if (followCamera != null)
        {
            followCamera.Follow = playerStats.transform;
            followCamera.LookAt = playerStats.transform;
        }
    }

    public void AddObserver(IEndGameObserve observe)
    {
        endGameObserves.Add(observe);
    }

    public void RemoveObserver(IEndGameObserve observe)
    {
        endGameObserves.Remove(observe);
    }

    public void NotifyObservers()
    {
        foreach (var observe in endGameObserves)
        {
            observe.EndNotify();
        }
        SceneController.Instance.BackToBegin();
    }

    public void setUIMs(String Ms, bool isShow)
    {
        MainUI.transform.GetChild(3).gameObject.SetActive(isShow);
        MainUI.transform.GetChild(3).GetComponentInChildren<Text>().text = Ms;
    }
}
