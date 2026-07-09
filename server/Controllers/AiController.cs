using AiServer.Models;
using Microsoft.AspNetCore.Mvc;
using server.Services.Rag;

namespace AiServer.Controllers;

[ApiController]
[Route("[controller]")]
public class AiController : ControllerBase
{
    private readonly IRagService _rag;
    private readonly ILogger<AiController> _logger;

    public AiController(IRagService rag, ILogger<AiController> logger)
    {
        _rag = rag;
        _logger = logger;
    }

    [HttpPost("chat")]
    public async Task<ActionResult<ChatResponse>> Chat([FromBody] ChatRequest req)
    {
        if (req.Messages == null || req.Messages.Count == 0)
            return BadRequest("Messages empty");

        // ✅ מוצאים הודעת USER אחרונה בלבד
        var lastUserMessage = req.Messages
            .LastOrDefault(m => m.Role == "user" && !string.IsNullOrWhiteSpace(m.Text));

        if (lastUserMessage == null)
            return BadRequest("No user message");

        var userText = lastUserMessage.Text!;

        _logger.LogInformation("RAG request: {Msg}", userText);

        var reply = await _rag.GenerateTrainingAsync(userText);

        return Ok(new ChatResponse { Reply = reply });
    }
}