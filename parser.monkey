Strict

Import mojo.app
Import fuzzy.fuzzy

#Rem
	Summary: Parses a *.fzg (fuzzy grammar) file and constructs fuzzy modules accordingly
#END
Class FuzzyParser

	#Rem
		Summary: Path to grammar file
	#END
	Field FilePath:String

	#Rem
		Summary: Create a new FuzzyParser
	#END
	Method New(filepath:String)
		Self.FilePath = filepath
	End

	#Rem
		Summary: Parse grammar file and return a StringMap with the newly created fuzzy modules

		Grammar:
			fm             = "FM" string
			flv            = "FLV" string
			lss            = "LEFT_SHOULDER_SET" min peak max
			ts             = "TRIANGLE_SET" min peak max
			rss            = "RIGHT_SHOULDER_SET" min peak max
			ss             = "SINGLETON_SET" min peak max
			settype        = lss | ts | rss | ss
			set            = "SET" setname settype
			rule           = "RULE" ruleset IS setname
			ruleset        = setname | setname operator setname
			operator       = AND | OR
			desirability   = Undesirable | Desirable | VeryDesirable
			min, peak, max = int
			setname        = string

		Example:
			FM AttackGunWeapon
				FLV DistToTarget
					SET TargetClose LEFT_SHOULDER_SET 0 10 20
					SET TargetMedium TRIANGLE_SET 10 20 30
					SET TargetFar RIGHT_SHOULDER_SET 20 30 40
				FLV Ammo
					SET AmmoLow LEFT_SHOULDER_SET 0 10 20
					SET AmmoMedium TRIANGLE_SET 10 20 30
					SET AmmoHigh RIGHT_SHOULDER_SET 20 30 40
				FLV Desirability
					SET Undesirable LEFT_SHOULDER_SET 0 25 50
					SET Desirable TRIANGLE_SET 25 50 75
					SET VeryDesirable RIGHT_SHOULDER_SET 50 75 100
				RULE TargetClose IS VeryDesirable
				RULE TargetMedium IS VeryDesirable
				RULE TargetFar IS Undesirable
				'Or combine terms, grammar supports a max of 2
				RULE TargetClose OR TargetMedium IS VeryDesirable
				RULE TargetFAR AND AmmoHigh Desirably
		
		Note: The parser only has limited support for creating RULES. In code you could do `Fairly(TargetFar) And (AmmoLow Or AmmoMedium) Then Desirable`.
		But the parser does not support this syntax. Instead you're limited to either one of the following (look up for a more expressive example):
		
		- setname
		- setname AND setname
		- setname OR setname
		
		If a RULE line is found that can't be parsed a FuzzyParserException might get thrown.
		
		The returned result is a StringMap containing FuzzyModule objects. Use the name of the Fuzzy Module as the key to get the Fuzzy Module.
	#END
	Method Parse:StringMap<FuzzyModule>()
	
		Local fms:StringMap<FuzzyModule> = New StringMap<FuzzyModule>
		Local flvs:StringMap<FuzzyVariable> = New StringMap<FuzzyVariable>
		Local sets:StringMap<FzSet> = New StringMap<FzSet>
		
		Local fm:FuzzyModule
		Local flv:FuzzyVariable

		Local set:FzSet

		Local input:String = LoadString(Self.FilePath)
		Local lines:String[] = input.Split("~r~n")
		For Local line:String = EachIn lines
			Local trimmed:String = line.Trim()
			'Skip empty lines
			If trimmed.Length = 0 Then Continue
			'Skip comment lines
			If trimmed.StartsWith("'") Then Continue
			Local parts:String[] = trimmed.Split(" ")
			Local type:String = parts[0]
			Select type
				Case "FM"
					flvs.Clear()
					sets.Clear()
					fm = New FuzzyModule
					fms.Add(parts[1], fm)
				Case "FLV"
					flv = fm.CreateFLV(parts[1])
					flvs.Add(parts[1], flv)
				Case "SET"
					Local setname:String = parts[1]
					Local settype:String = parts[2]
					Local min:Int = Int(parts[3])
					Local peak:Int = Int(parts[4])
					Local max:Int = Int(parts[5])
					Select settype
						Case "LEFT_SHOULDER_SET"
							set = flv.AddLeftShoulderSet(setname, min, peak, max)
						Case "RIGHT_SHOULDER_SET"
							set = flv.AddRightShoulderSet(setname, min, peak, max)
						Case "TRIANGLE_SET"
							set = flv.AddTriangularSet(setname, min, peak, max)
						Case "SINGLETON_SET"
							set = flv.AddSingletonSet(setname, min, peak, max)
					End
					sets.Add(setname, set)
				Case "RULE"
					Local result:FzSet = sets.Get(parts[parts.Length - 1])
					If result = Null Then Throw New FuzzyParserException("Result term " + parts[parts.Length - 1] + " not found in set!")
					'RULE foobar IS desirability
					'setname
					If parts.Length = 4
						fm.AddRule(sets.Get(parts[1]), result)
					'setname operator setname - no other variations are supported for the time being
					ElseIf parts.Length = 6
						Local operator:String = parts[2]
						Local term1:FzSet = sets.Get(parts[1])
						Local term2:FzSet = sets.Get(parts[3])
						If term1 = Null Then Throw New FuzzyParserException("Term " + parts[1] + " not found in set!")
						If term2 = Null Then Throw New FuzzyParserException("Term " + parts[3] + " not found in set!")
						Select operator
							Case "AND"
								fm.AddRule(New FzAND(term1, term2), result)
							Case "OR"
								fm.AddRule(New FzOR(term1, term2), result)
						End
					Else
						Throw New FuzzyParserException("Not yet implemented")
					EndIf
				Default
					Throw New FuzzyParserException("Can not parse line: " + trimmed)
			End
		Next
		Return fms
	End
End

#Rem
	Summary: Exception class for FuzzyParser
#END
Class FuzzyParserException Extends Throwable
	Field msg:String

	Method New( msg:String )
		Self.msg=msg
	End
End