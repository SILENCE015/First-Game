using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class RoomGenerator : MonoBehaviour
{
    public enum Direction { up, down, left, right };
    public Direction direction;

    [Header("房间信息")]
    public GameObject roomPrefab;
    public int roomNumber;
    public int lastNumber;
    private int num;
    public Color startColor, endColor, shopColor;
    private GameObject endRoom;
    private GameObject shopRoom;

    [Header("位置控制")]
    public Transform generatorPoint;
    public float xOffset;
    public float zOffset;
    public LayerMask roomLayer;

    public int maxStep;
    public List<Room> rooms = new List<Room>();

    List<GameObject> farRooms = new List<GameObject>();
    List<GameObject> lessFarRooms = new List<GameObject>();
    List<GameObject> oneWayRooms = new List<GameObject>();

    void Start()
    {
        for (int i = 0; i < Random.Range(lastNumber, roomNumber); i++)
        {
            rooms.Add(Instantiate(roomPrefab, generatorPoint.position, Quaternion.identity).GetComponent<Room>());
            // 改变point位置
            ChangePointPos();
        }

        rooms[0].GetComponent<Room>().roomType = Room.RoomType.StartRoom;
        rooms[0].plane.material.color = startColor;
        endRoom = rooms[0].gameObject;


        foreach (var room in rooms)
        {
            SetupRoom(room, room.transform.position, rooms.IndexOf(room));
        }

        FindEndRoom();
        endRoom.GetComponent<Room>().roomType = Room.RoomType.LastRoom;
        endRoom.GetComponent<Room>().plane.material.color = endColor;
        FindShop();
    }

    void Update()
    {
        // if (Input.anyKeyDown)
        // {
        //     SceneManager.LoadScene(SceneManager.GetActiveScene().name);
        // }
    }

    public void ChangePointPos()
    {
        do
        {
            direction = (Direction)Random.Range(0, 4);

            switch (direction)
            {
                case Direction.up:
                    generatorPoint.position += new Vector3(0, 0, zOffset);
                    break;
                case Direction.down:
                    generatorPoint.position += new Vector3(0, 0, -zOffset);
                    break;
                case Direction.left:
                    generatorPoint.position += new Vector3(-xOffset, 0, 0);
                    break;
                case Direction.right:
                    generatorPoint.position += new Vector3(xOffset, 0, 0);
                    break;
            }
        } while (Physics.OverlapBox(generatorPoint.position, new Vector3(0.2f, 0.2f, 0.2f), Quaternion.identity, roomLayer).Length == 0 ? false : true);
    }

    public void SetupRoom(Room newRoom, Vector3 roomPosition, int number)
    {
        newRoom.roomUp = Physics.OverlapBox(roomPosition + new Vector3(0, 0, zOffset), new Vector3(0.2f, 0.2f, 0.2f), Quaternion.identity, roomLayer).Length == 0 ? false : true;
        newRoom.roomDown = Physics.OverlapBox(roomPosition + new Vector3(0, 0, -zOffset), new Vector3(0.2f, 0.2f, 0.2f), Quaternion.identity, roomLayer).Length == 0 ? false : true;
        newRoom.roomLeft = Physics.OverlapBox(roomPosition + new Vector3(-xOffset, 0, 0), new Vector3(0.2f, 0.2f, 0.2f), Quaternion.identity, roomLayer).Length == 0 ? false : true;
        newRoom.roomRight = Physics.OverlapBox(roomPosition + new Vector3(xOffset, 0, 0), new Vector3(0.2f, 0.2f, 0.2f), Quaternion.identity, roomLayer).Length == 0 ? false : true;

        newRoom.UpdateRoom(xOffset, zOffset, number);
        newRoom.gameObject.name = "Room" + number;
    }

    public void FindEndRoom()
    {
        // 最大数值
        for (int i = 0; i < rooms.Count; i++)
        {
            if (rooms[i].stepToStart > maxStep)
                maxStep = rooms[i].stepToStart;
        }
        // 获得最大值房间和次
        foreach (var room in rooms)
        {
            if (room.stepToStart == maxStep)
                farRooms.Add(room.gameObject);
            if (room.stepToStart == maxStep - 1)
                lessFarRooms.Add(room.gameObject);
        }

        for (int i = 0; i < farRooms.Count; i++)
        {
            if (farRooms[i].GetComponent<Room>().doorNumber == 1)
                oneWayRooms.Add(farRooms[i]);
        }
        for (int i = 0; i < lessFarRooms.Count; i++)
        {
            if (lessFarRooms[i].GetComponent<Room>().doorNumber == 1)
                oneWayRooms.Add(lessFarRooms[i]);
        }

        if (oneWayRooms.Count != 0)
        {
            endRoom = oneWayRooms[Random.Range(0, oneWayRooms.Count)];
        }
        else
        {
            endRoom = farRooms[Random.Range(0, farRooms.Count)];
        }
    }

    public void FindShop()
    {
        do
        {
            num = Random.Range(0, roomNumber - 1);
            if (rooms[num].GetComponent<Room>().roomType == Room.RoomType.BaseRoom)
            {
                shopRoom = rooms[num].gameObject;
                shopRoom.GetComponent<Room>().roomType = Room.RoomType.shop;
                shopRoom.GetComponent<Room>().plane.material.color = shopColor;
            }
        } while (rooms[num].GetComponent<Room>().roomType != Room.RoomType.shop);
    }
}