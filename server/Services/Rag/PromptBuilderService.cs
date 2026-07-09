namespace server.Services.Rag;

public class PromptBuilderService
{
    public string BuildPrompt(
        string userRequest,
        List<string> examples)
    {
       // var knowledgeBlock = string.Join("\n\n", knowledge);
        var exampleBlock = string.Join("\n\n", examples);

        return $"""
            You are a professional football AI coach.

            RULES:
            - Output ONLY valid JSON
            - No explanations
            - Use Items and Trajectories schema

            SCHEMA:
            {GetSchema()}

            EXAMPLES:
            {exampleBlock}

            USER REQUEST:
            {userRequest}

            Generate football training JSON.
            """;
    }

    private string GetSchema() =>
    """
    JSON format:
    {
      ""Items"": [
        { ""Id"": ""string"", ""Type"": ""player | cone | kickWall | agilityLadder | ball | rebounder"", ""X"": number, ""Y"": number }
      ],
      ""Trajectories"": [
        {
          ""Id"": ""string"",
          ""Type"": ""run | dribble | shoot | highKnees | slalomSideToSide | slalomSole | slalomRightLeg | controllSolePass | controllSideToSide | controllSole | passingRebounderNonStop | passingRebounderPullPass | passingRebounderPullFlash"",
          ""Points"": [{ ""X"": number, ""Y"": number }]
        }
      ]
    }
    """;
}