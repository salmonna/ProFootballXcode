namespace server.Services.Rag;

public interface IRagService
{
    Task<string> GenerateTrainingAsync(string userRequest);
}