using Microsoft.AspNetCore.Cors;
using Microsoft.AspNetCore.Mvc;
using System.Diagnostics;
using System.Text.Json;
using WebApplication1.Models;

using Google.Cloud.Storage.V1;
using Google.Apis.Auth.OAuth2;

using System.IO;

namespace WebApplication1.Controllers
{

    [ApiController]
    [Route("[controller]")]
    [EnableCors("AllowAll")]

    public class ItemsController : ControllerBase
    {
        private readonly ILogger<ItemsController> _logger;
        public ItemsController(ILogger<ItemsController> logger)
        {
            _logger = logger;
        }

        [HttpPost]
        public async Task<IActionResult> Post([FromBody] ItemsRequest request)
        {
            _logger.LogInformation("🔥 POST /Items HIT");
            _logger.LogInformation("Received video generation request with {ItemCount} items and {TrajectoryCount} trajectories",
            request.Items?.Count ?? 0, request.Trajectories?.Count ?? 0);

            string userId = HttpContext.Items["UserId"]?.ToString();

            if (string.IsNullOrEmpty(userId))
            {
                _logger.LogWarning("Unauthorized request: Missing UserID");
                return Unauthorized();
            }

            // 2. הגדרת נתיבי עבודה
            string baseFolder = Path.Combine("/tmp/ProjectData", userId);
            string inputJsonPath = Path.Combine(baseFolder, "input.json");
            string outputFolder = Path.Combine("/tmp/Records", userId);
            string videoFileName = $"Match_{DateTime.Now:yyyyMMdd_HHmmss}.mp4";
            string finalVideoPath = "/app/videos/output_video.mp4";
            //string finalVideoPath = Path.Combine(outputFolder, "output_video.mp4");

            _logger.LogInformation("Processing video request for User: {UserId}", userId);

            try
            {
                // 3. הכנת סביבת עבודה
                Directory.CreateDirectory(baseFolder);
                Directory.CreateDirectory(outputFolder);
                // 4. שמירת קובץ הנתונים עבור Unity
                // string json = JsonSerializer.Serialize(request);
                string json = JsonSerializer.Serialize(request, new JsonSerializerOptions
                {
                    WriteIndented = true // עושה פורמט יפה
                });

                string filePath = Path.Combine(baseFolder, "input.json");

                System.IO.File.WriteAllText(filePath, json);

                _logger.LogInformation($"JSON saved to: {filePath}");
                _logger.LogInformation("json: ", json);
                string jsonBase64 = Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(json));

                // 5. הרצת Unity
                _logger.LogInformation("Launching Unity Build...");
                //Process.Start("Xvfb", ":99 -screen 0 1280x720x24");

                // ⏱ התחלת מדידת זמן
                var stopwatch = Stopwatch.StartNew();

                var useGpu = Environment.GetEnvironmentVariable("USE_GPU") == "true";
                var renderer = useGpu ? "-force-vulkan" : "-force-opengl";

                var unityInfo = new ProcessStartInfo
                {
                    FileName = "/app/unity/UnityProFootball.x86_64",
                    Arguments = $"-batchmode -screen-width 1280 -screen-height 720 -logFile - " +
                                $"-jsonBase64 \"{jsonBase64}\"",
                    UseShellExecute = false,
                    CreateNoWindow = true,
                    RedirectStandardError = true,
                    RedirectStandardOutput = true
                };

                unityInfo.EnvironmentVariables["DISPLAY"] = ":99";
                if (!useGpu)
                    unityInfo.EnvironmentVariables["GALLIUM_DRIVER"] = "llvmpipe";

                using (var unity = new Process())
                {
                    unity.StartInfo = unityInfo;
                    // פקודות לקבלת הפלט בזמן אמת
                    unity.OutputDataReceived += (sender, args) =>
                    {
                        if (!string.IsNullOrEmpty(args.Data))
                            _logger.LogInformation("[Unity] " + args.Data);
                    };

                    unity.ErrorDataReceived += (sender, args) =>
                    {
                        if (!string.IsNullOrEmpty(args.Data))
                            _logger.LogError("[Unity Error] " + args.Data);
                    };

                    unity.Start();

                    // התחלת קריאה אסינכרונית
                    unity.BeginOutputReadLine();
                    unity.BeginErrorReadLine();


                    // מחכה עד 4 דקות לסיום
                    if (!unity.WaitForExit(1000000))
                    {
                        _logger.LogError("Unity Process Timed Out!");
                        unity.Kill();
                        return StatusCode(504, "Rendering timeout");
                    }

                    stopwatch.Stop(); // עצירת מדידה
                    _logger.LogInformation($"Unity finished successfully in {stopwatch.Elapsed.TotalSeconds:F2}");
                }

                _logger.LogInformation("Unity process exited. Starting Firebase sequence...");
                // ✅ בדיקה שנוצר וידאו
                if (!System.IO.File.Exists(finalVideoPath))
                {
                    _logger.LogError("Unity did not create video at {Path}", finalVideoPath);
                    return StatusCode(500, "Video generation failed.");
                }

                var uploadStopwatch = Stopwatch.StartNew();
                // 🔥 Upload to Firebase Storage
                var credential = GoogleCredential.FromFile("/app/firebase-key.json");
                var storage = StorageClient.Create(credential);

                string bucket = "profotball1.firebasestorage.app";
                string firebaseFileName = $"videos/{userId}/{videoFileName}";
                _logger.LogInformation($"starting read... {stopwatch.Elapsed.TotalSeconds:F2}");
                using (var stream = System.IO.File.OpenRead(finalVideoPath))
                {
                    _logger.LogInformation("Uploading to Firebase...");
                    await storage.UploadObjectAsync(
                        bucket,
                        firebaseFileName,
                        "video/mp4",
                        stream
                    );
                }
                uploadStopwatch.Stop();

                _logger.LogInformation("Firebase Upload completed in {Seconds:F2}s", uploadStopwatch.Elapsed.TotalSeconds);
                string firebaseUrl = $"https://storage.googleapis.com/{bucket}/{firebaseFileName}";

                System.IO.File.Delete(finalVideoPath);

                return Ok(new
                {
                    videoName = videoFileName,
                    firebaseUrl = firebaseUrl,
                    message = "Video created successfully"
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Critical error in ItemsController for user {UserId}", userId);
                return StatusCode(500, $"Internal Server Error: {ex.Message}");
            }
        }
    }
}