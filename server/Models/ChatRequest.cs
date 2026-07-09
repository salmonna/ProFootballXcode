namespace AiServer.Models;

public class ChatRequest
{
    public List<ClientMessage> Messages { get; set; } = new();
}

public class ClientMessage
{
    public string Role { get; set; } = "";
    public string? Text { get; set; }
}