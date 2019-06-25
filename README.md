# Powershell-Trivia
A trivia game written in PowerShell Using the Open Trivia Database (https://opentdb.com/api_config.php)

Launch Powershell-Trivia.ps1 to start a game. 

You can also import it as a module and create custom games.

Functions include:

### Get-TriviaCategories 
  
  Lists all available categories

### Get-TriviaQuestion
 
 Returns 1 random trivia question.
  
### Invoke-TriviaGame -NumberOfQuestions 10 -Difficulty easy -SelectCategory
  
  Starts an easy round with 10 questions. Provides a menu for selecting a category.
