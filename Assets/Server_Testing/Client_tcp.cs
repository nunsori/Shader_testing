using UnityEngine;
using System;
using System.Net.Sockets;
using System.Text;
using System.Threading.Tasks;
using Unity.VisualScripting;

public class Client_tcp : MonoBehaviour
{
    private TcpClient client;
    private NetworkStream stream;

    // 서버 IP와 포트를 설정합니다.
    //private string serverIP = "127.0.0.1"; // 로컬 호스트 IP
    private string serverIP = "192.168.0.47"; // 로컬 호스트 IP
    private int serverPort = 8080;

    async void Start()
    {
        await ConnectToServer();
    }

    private async Task ConnectToServer()
    {
        try
        {
            // TCP 클라이언트를 서버에 연결
            client = new TcpClient();
            await client.ConnectAsync(serverIP, serverPort);
            Debug.Log("Connected to server");

            stream = client.GetStream();

            // 서버로 메시지 보내기
            await SendMessage("Hello from Unity client");

            // 서버 응답 수신
            await ReceiveMessage();
        }
        catch (Exception e)
        {
            Debug.LogError($"Connection error: {e.Message}");
        }
    }

    private async Task SendMessage(string message)
    {
        if (stream == null) return;

        byte[] data = Encoding.UTF8.GetBytes(message);
        await stream.WriteAsync(data, 0, data.Length);
        Debug.Log("Message sent to server: " + message);
    }

    private async Task ReceiveMessage()
    {
        if (stream == null) return;

        byte[] buffer = new byte[1024];
        int bytesRead = await stream.ReadAsync(buffer, 0, buffer.Length);
        string response = Encoding.UTF8.GetString(buffer, 0, bytesRead);
        Debug.Log("Received from server: " + response);
    }

    private void OnApplicationQuit()
    {
        // 클라이언트 연결 종료
        if (stream != null) stream.Close();
        if (client != null) client.Close();
        Debug.Log("Disconnected from server");
    }
}
