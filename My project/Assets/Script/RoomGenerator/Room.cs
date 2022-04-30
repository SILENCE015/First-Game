using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class Room : MonoBehaviour
{
    public enum RoomType { BaseRoom, StartRoom, LastRoom, shop };
    public RoomType roomType;
    public GameObject doorLeft, doorRight, doorUp, doorDown;
    public GameObject doors;
    public GameObject baseRoom;
    public bool roomLeft, roomRight, roomUp, roomDown;
    public int stepToStart;
    public int doorNumber;
    public Renderer plane;
    public int roomNumber;
    public GameObject transDoor;
    public GameObject shop;
    public bool isClear = false;
    public GameObject nextLevel;

    void Start()
    {
        HideRoom();
        doorLeft.SetActive(roomLeft);
        doorRight.SetActive(roomRight);
        doorUp.SetActive(roomUp);
        doorDown.SetActive(roomDown);
        doors.SetActive(false);
        RoomeDe();
    }

    void Update()
    {
        if(roomType == RoomType.LastRoom && isClear)
        {
            nextLevel.SetActive(true);
        }
        if(GameManager.Instance.GameLevel == 5)
        {
            Debug.Log("LastLevel");
            transDoor.GetComponent<TransitionPoint>().isLast = true;
        }
    }

    void HideRoom()
    {
        baseRoom.gameObject.SetActive(false);
    }

    public void UpdateRoom(float xOffset, float zOffset, int number)
    {
        stepToStart = (int)(Mathf.Abs(transform.position.x / xOffset) + Mathf.Abs(transform.position.z / zOffset));
        roomNumber = number;

        if (roomUp)
            doorNumber++;
        if (roomDown)
            doorNumber++;
        if (roomLeft)
            doorNumber++;
        if (roomRight)
            doorNumber++;
    }

    //TODO:判断房间类型
    private void RoomeDe()
    {
        //TODO:lastRoom生成去Boos房的传送门
        //TODO:shopRoom生成商店
        //TODO:baseRoom生成怪物
        if(roomType == RoomType.shop)
        {
            Instantiate(shop, new Vector3(transform.position.x + 20, transform.position.y, transform.position.z), transform.rotation);
            Instantiate(shop, transform.position, transform.rotation);
            Instantiate(shop, new Vector3(transform.position.x - 20, transform.position.y, transform.position.z), transform.rotation);
        }
        if (roomType == RoomType.LastRoom)
        {
            UnityEngine.Debug.Log(roomType + ";" + roomNumber);
            nextLevel = Instantiate(transDoor, this.transform.position, this.transform.rotation);
            nextLevel.SetActive(false);
            // float a = int.Parse(SceneManager.GetActiveScene().name.Substring(6, 1));
            // a += 1;
            // UnityEngine.Debug.Log(a);
            // GameObject ppp = Instantiate(SceneController.Instance.pppp, this.transform.position, this.transform.rotation);
            // ppp.name = "Level0" + a;
            // ppp.transform.parent = this.transform;
        }
    }
    //TODO:生成怪物
}
