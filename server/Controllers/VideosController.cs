using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Cors;
using Microsoft.AspNetCore.Authorization;
using WebApplication1.Models;
using System.Text;

namespace WebApplication1.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [EnableCors("AllowAll")]
    public class VideosController : ControllerBase
    {
        private readonly string baseRecordsPath = @"C:\Temp\Records";

        // UID שנשמר ע"י FirebaseAuthMiddleware
        private string? UserId =>
            HttpContext.Items["UserId"]?.ToString();

        // -------------------------------
        // GET: /Videos
        // -------------------------------
        [HttpGet]
        public IActionResult GetVideos()
        {
            if (UserId == null)
                return Unauthorized();

            var userFolder = Path.Combine(baseRecordsPath, UserId);

            if (!Directory.Exists(userFolder))
                return Ok(new List<VideoInfo>());

            var files = Directory.GetFiles(userFolder, "*.mp4");

            var list = files
                .Select(f => new VideoInfo
                {
                    FileName = Path.GetFileName(f),
                    CreatedAt = System.IO.File.GetCreationTime(f)
                })
                .OrderByDescending(v => v.CreatedAt)
                .ToList();

            return Ok(list);
        }

        // -------------------------------
        // GET: /Videos/stream-token/{fileName}
        // -------------------------------
        [HttpGet("stream-token/{fileName}")]
        public IActionResult GetStreamToken(string fileName)
        {
            if (UserId == null)
                return Unauthorized();

            // token קצר-חיים (5 דקות)
            var payload = $"{UserId}|{fileName}|{DateTime.UtcNow.AddMinutes(5):O}";
            var token = Convert.ToBase64String(Encoding.UTF8.GetBytes(payload));

            return Ok(new { token });
        }

        // -------------------------------
        // GET: /Videos/stream/{fileName}?token=...
        // -------------------------------
        [HttpGet("stream/{userId}/{fileName}")]
        [AllowAnonymous]
        public IActionResult Stream(string userId, string fileName)
        {
            var fullPath = Path.Combine(baseRecordsPath, userId, fileName);

            if (!System.IO.File.Exists(fullPath))
                return NotFound();

            var stream = new FileStream(
                fullPath,
                FileMode.Open,
                FileAccess.Read,
                FileShare.Read
            );

            return File(stream, "video/mp4", enableRangeProcessing: true);
        }


        // -------------------------------
        // DELETE: /Videos/{fileName}
        // -------------------------------
        [HttpDelete("{fileName}")]
        public IActionResult Delete(string fileName)
        {
            if (UserId == null)
                return Unauthorized();

            var fullPath = Path.Combine(baseRecordsPath, UserId, fileName);

            if (!System.IO.File.Exists(fullPath))
                return NotFound();

            try
            {
                System.IO.File.Delete(fullPath);
                return Ok(new { message = "Deleted successfully" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, ex.Message);
            }
        }
    }
}
