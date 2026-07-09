using Microsoft.AspNetCore.Mvc;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    [HttpGet("secure")]
    public IActionResult Secure()
    {
        return Ok("Authorized 🔐");
    }
}
