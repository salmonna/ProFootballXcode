using FirebaseAdmin.Auth;

public class FirebaseAuthMiddleware
{
    private readonly RequestDelegate _next;

    public FirebaseAuthMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task Invoke(HttpContext context)
    {
        if (context.Request.Path.StartsWithSegments("/Ai/chat") || context.Request.Path.StartsWithSegments("/Videos/stream"))
        {
            await _next(context);
            return;
        }
            var authHeader = context.Request.Headers["Authorization"].FirstOrDefault();

        if (authHeader == null || !authHeader.StartsWith("Bearer "))
        {
            context.Response.StatusCode = 401;
            return;
        }

        var token = authHeader.Substring("Bearer ".Length);

        try
        {
            var decodedToken = await FirebaseAuth.DefaultInstance.VerifyIdTokenAsync(token);

            // 🔥 שומרים UID אמיתי
            context.Items["UserId"] = decodedToken.Uid;

            await _next(context);
        }
        catch
        {
            context.Response.StatusCode = 401;
        }
    }
}
