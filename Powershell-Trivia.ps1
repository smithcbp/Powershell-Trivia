
function Get-TriviaCategories
{
	$categoriesrequest = Invoke-RestMethod -Uri "https://opentdb.com/api_category.php"
	$categoriesrequest.trivia_categories
}

function Get-TriviaQuestion
{
	[cmdletbinding()]
	param (
		[Parameter()]
		[ValidateSet('easy', 'medium', 'hard')]
		[string]$Difficulty,
		[int]$CategoryID
		
	)
	if ($Difficulty -and $CategoryID) { $request = Invoke-RestMethod -Uri "https://opentdb.com/api.php?amount=1&difficulty=$difficulty&category=$CategoryID" }
	elseif ($Difficulty) { $request = Invoke-RestMethod -Uri "https://opentdb.com/api.php?amount=1&difficulty=$difficulty" }
	elseif ($CategoryID) { $request = Invoke-RestMethod -Uri "https://opentdb.com/api.php?amount=1&category=$CategoryID" }
	else { $request = Invoke-RestMethod -Uri "https://opentdb.com/api.php?amount=1" }
	
	$fullquestion = [pscustomobject]@{
		Question = ($request.results | Select-Object -ExpandProperty question)
		Category = ($request.results | Select-Object -ExpandProperty category)
		Correct_Answer = ($request.results | Select-Object -ExpandProperty correct_answer)
		Incorrect_Answers = ($request.results | Select-Object -ExpandProperty incorrect_answers)
		Difficulty = ($request.results | Select-Object -ExpandProperty difficulty)
		All_Answers = (@($request.results | Select-Object -ExpandProperty correct_answer) + ($request.results | Select-Object -ExpandProperty incorrect_answers))
	}
	
    $fullquestion.Question = $fullquestion.Question.replace('&quot;', '"')
    $fullquestion.Question = $fullquestion.Question.replace('<[^>]+>', '')
    $fullquestion.Question = $fullquestion.Question.replace('&#39;', "'")
    $fullquestion.Question = $fullquestion.Question.replace('&#039;', "'")
    $fullquestion.Question = $fullquestion.Question.replace('&#32;', ' ')
    $fullquestion.Question = $fullquestion.Question.replace('&eacute;', 'é')
    $fullquestion.Correct_Answer = $fullquestion.Correct_Answer.replace('&quot;', '"')
    $fullquestion.Correct_Answer = $fullquestion.Correct_Answer.replace('<[^>]+>', '')
    $fullquestion.Correct_Answer = $fullquestion.Correct_Answer.replace('&#39;', "'")
    $fullquestion.Correct_Answer = $fullquestion.Correct_Answer.replace('&#039;', "'")
    $fullquestion.Correct_Answer = $fullquestion.Correct_Answer.replace('&#32;', ' ')
    $fullquestion.Correct_Answer = $fullquestion.Correct_Answer.replace('&eacute;', 'é')
    $fullquestion.InCorrect_Answers = $fullquestion.InCorrect_Answers.replace('&quot;', '"')
    $fullquestion.InCorrect_Answers = $fullquestion.InCorrect_Answers.replace('<[^>]+>', '')
    $fullquestion.InCorrect_Answers = $fullquestion.InCorrect_Answers.replace('&#39;', "'")
    $fullquestion.InCorrect_Answers = $fullquestion.InCorrect_Answers.replace('&#039;', "'")
    $fullquestion.InCorrect_Answers = $fullquestion.InCorrect_Answers.replace('&#32;', ' ')
    $fullquestion.InCorrect_Answers = $fullquestion.InCorrect_Answers.replace('&eacute;', 'é')
    $fullquestion.All_Answers = $fullquestion.All_Answers.replace('&quot;', '"')
    $fullquestion.All_Answers = $fullquestion.All_Answers.replace('<[^>]+>', '')
    $fullquestion.All_Answers = $fullquestion.All_Answers.replace('&#39;', "'")
    $fullquestion.All_Answers = $fullquestion.All_Answers.replace('&#039;', "'")
    $fullquestion.All_Answers = $fullquestion.All_Answers.replace('&#32;', ' ')
    $fullquestion.All_Answers = $fullquestion.All_Answers.replace('&eacute;', 'é')
    
	$RandomAnswers = $fullquestion.All_Answers | Sort-Object { Get-Random }
	$i = 0
	$RandomAnswers | ForEach-Object {
		$i++
		$_ | Add-Member NoteProperty "Number" -Value $i
		$_ | Add-Member NoteProperty "AnswerText" -Value $_
	}
	
	
	Write-Host -ForegroundColor Gray "`nCategory: $($fullquestion.Category)`n"
	
	
	Write-Host -ForegroundColor Yellow "Question: $($fullquestion.Question)`n"
	
	Foreach ($answer in $RandomAnswers)
	{
		Write-Host -ForegroundColor Cyan "$($answer.Number).) $($answer.Answertext)"
	}
	Write-Host "`nType your answer:[1-$($RandomAnswers.Count)]:"
	$SelectedAnswerNumber = Read-Host
	$SelectedAnswer = $RandomAnswers | Where-Object Number -Like $SelectedAnswerNumber
	if ($SelectedAnswer -like ($($fullquestion.Correct_Answer)))
	{
		Write-Output "Correct"
		Write-Host "Correct!"
	}
	else
	{
		Write-Output "Wrong"
		Write-Host "Incorrect. The correct answer was $($fullquestion.Correct_Answer)"
	}
}

Function Invoke-TriviaGame
{
	
	param (
		[Parameter()]
		[ValidateSet('easy', 'medium', 'hard')]
		[string]$Difficulty,
		[Parameter()]
		[int]$NumberOfQuestions = 10,
		[Parameter()]
		[Switch]$SelectCategory,
		[Parameter()]
		[Int]$CategoryId
	)
	
	if ($SelectCategory)
	{
		$Categories = Get-TriviaCategories
		$Categories | Format-Table
		$Prompt = Read-Host -Prompt "Which Category?"
		$CategoryName = $Categories | Where-Object { ($_.id -match $Prompt) -or ($_.name -match $Prompt) } | Select-Object -ExpandProperty Name
		$CategoryId = $Categories | Where-Object { ($_.id -match $Prompt) -or ($_.name -match $Prompt) } | Select-Object -ExpandProperty id
	}
	
	$i = 0
	$FinalTally = @()
	$FinalTally += 1 .. $NumberOfQuestions | ForEach-Object {
		$i++
		Clear-Host
		Write-Host "Question $i of $NumberOfQuestions"
		if ($Difficulty -and $CategoryId) { Get-TriviaQuestion -Difficulty $Difficulty -CategoryID $CategoryId }
		elseif ($Difficulty) { Get-TriviaQuestion -Difficulty $Difficulty }
		elseif ($CategoryId) { Get-TriviaQuestion -CategoryID $CategoryId }
		else { Get-TriviaQuestion }
		Start-Sleep -Seconds 2
	}

	$Score = $FinalTally | Group-Object
	$CorrectScore = $Score | Where-Object Name -Like "Correct"
	Clear-Host
	
	if ($Difficulty -or $CategoryName){ Write-Host "Game Settings: $Difficulty $CategoryName" }	
	Write-Host -ForegroundColor Green "Your Final Score Was $($CorrectScore.Count) out of $NumberOfQuestions"
}