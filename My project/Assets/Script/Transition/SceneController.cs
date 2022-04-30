using System.Diagnostics;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class SceneController : Singleton<SceneController>
{
    public GameObject playerPrefab;
    public GameObject pppp;
    GameObject player;

    public GameObject loadScreen;
    public Slider slider;
    public Text text;

    protected override void Awake()
    {
        base.Awake();
        DontDestroyOnLoad(this);
    }

    public void TransitionToDestination(TransitionPoint transitionPoint)
    {
        StartCoroutine(DifferentTransition(transitionPoint.destinationTag));
    }

    IEnumerator DifferentTransition(TransitionDestination.DestinationTag destinationTag)
    {
        // TODO:保存数据
        SaveManager.Instance.SavePlayerData();
        loadScreen.SetActive(true);
        AsyncOperation operation = SceneManager.LoadSceneAsync(SceneManager.GetActiveScene().buildIndex + 1);
        operation.allowSceneActivation = false;
        while (!operation.isDone)
        {
            slider.value = operation.progress;

            text.text = "Loading" + operation.progress * 100 + "%";

            if (operation.progress >= 0.9f)
            {
                slider.value = 1;

                text.text = "按下任何键继续";

                if (Input.anyKeyDown)
                {
                    operation.allowSceneActivation = true;
                }
            }

            yield return null;
        }
        yield return GameManager.Instance.GameLevel = SceneManager.GetActiveScene().buildIndex - 1;
        playerPrefab.transform.SetPositionAndRotation(new Vector3(0, 20, 0), this.transform.rotation);
        loadScreen.SetActive(false);
        yield break;

    }

    public void NextDoor(Portal.Door door, float destense, Vector3 position)
    {
        UnityEngine.Debug.Log("传送");
        player = GameManager.Instance.playerStats.gameObject;
        // Time.timeScale = 0;
        switch (door)
        {
            case Portal.Door.Up:
                UnityEngine.Debug.Log(new Vector3(position.x, position.y + 15, position.z + destense));
                player.transform.SetPositionAndRotation(new Vector3(position.x, position.y + 15, position.z + destense), this.transform.rotation);
                break;
            case Portal.Door.Down:
                UnityEngine.Debug.Log(new Vector3(position.x, position.y + 15, position.z + destense));
                player.transform.SetPositionAndRotation(new Vector3(position.x, position.y + 15, position.z - destense), this.transform.rotation);
                break;
            case Portal.Door.Left:
                UnityEngine.Debug.Log(new Vector3(position.x, position.y + 15, position.z + destense));
                player.transform.SetPositionAndRotation(new Vector3(position.x - destense, position.y + 15, position.z), this.transform.rotation);
                break;
            case Portal.Door.Right:
                UnityEngine.Debug.Log(new Vector3(position.x, position.y + 15, position.z + destense));
                player.transform.SetPositionAndRotation(new Vector3(position.x + destense, position.y + 15, position.z), this.transform.rotation);
                break;
        }
        // Time.timeScale = 1;
        UnityEngine.Debug.Log(player.transform.position);

    }

    private TransitionDestination GetDestination(TransitionDestination.DestinationTag destinationTag)
    {
        var entrances = FindObjectsOfType<TransitionDestination>();

        for (int i = 0; i < entrances.Length; i++)
        {
            if (entrances[i].destinationTag == destinationTag)
                return entrances[i];
        }

        return null;
    }

    public void BackToBegin()
    {
        Time.timeScale = 0;
        transform.GetChild(0).GetChild(4).gameObject.SetActive(true);
        if (Input.anyKeyDown)
        {
            Application.Quit();
        }
    }

    public void QuitGame()
    {
        Application.Quit();
    }
    public void StartGame()
    {
        GameManager.Instance.playerStats.gameObject.SetActive(true);
        Time.timeScale = 1;
        transform.GetChild(0).GetChild(5).gameObject.SetActive(false);
    }
    public void StopGame()
    {
        GameManager.Instance.playerStats.gameObject.SetActive(false);
        Time.timeScale = 0;
        transform.GetChild(0).GetChild(5).gameObject.SetActive(true);
    }
}
