Strict
#Rem
    This example represents how a AI agent would determine if it's undesirable, desirable or very desirable
    to use the weapon (a Rocket Launcher) at the opponent. There are 2 factors which influence the decision:
    Distance to the target and the amount of ammo. For a rocket launcher it's of course not smart to fire it
    from a short distance, and also not from a very far distance as it's not very fast and maybe it's direction
    will also alter. But when the distance is far but the agent has loads of ammo then of course it's worth a
    shot to try and hit the target (desirability=Desirable). So a medium distance is very desirable, depending
    on the amount of ammo.

    Now imagine that all your weapons have a method called CalculateDesirability(). Each weapon will hold its
    own fuzzy module to determine if it's wise to use the weapon in the current situation or not. The agent will
    have a method called SelectWeapon() which executes the CalculateDesirability() method of each available weapon
    and the weapon with the highest score will, most likely, be the best choice. More importantly, it would most
    likely be a decision a human would make as well. Of course, it all very much depends on how you've set your
    FLV's, which in turn can also be tweaked to make agents that make smart or dumb decisions.
#End
Import htbaa.fuzzy

Function Main:Int()
    Local fm:FuzzyModule = New FuzzyModule
    Local distToTarget:FuzzyVariable = fm.CreateFLV("DistToTarget")
    Local TargetClose:FzSet = distToTarget.AddLeftShoulderSet("TargetClose", 0, 25, 50)
    Local TargetMedium:FzSet = distToTarget.AddTriangularSet("TargetMedium", 25, 50, 75)
    Local TargetFar:FzSet = distToTarget.AddRightShoulderSet("TargetFar", 50, 75, 100)

    Local ammoStatus:FuzzyVariable = fm.CreateFLV("AmmoStatus")
    Local AmmoLoads:FzSet = ammoStatus.AddRightShoulderSet("AmmoLoads", 10, 30, 100)
    Local AmmoOkay:FzSet = ammoStatus.AddTriangularSet("AmmoOkay", 5, 10, 30)
    Local AmmoLow:FzSet = ammoStatus.AddTriangularSet("AmmoLow", 0, 5, 10)

    Local desirability:FuzzyVariable = fm.CreateFLV("Desirability")
    Local VeryDesirable:FzSet = desirability.AddRightShoulderSet("VeryDesirable", 50, 75, 100)
    Local Desirable:FzSet = desirability.AddTriangularSet("Desirable", 25, 50, 75)
    Local Undesirable:FzSet = desirability.AddLeftShoulderSet("Undesirable", 0, 25, 50)

    'If TargetClose And AmmoLoads Then Undesirable... And so on
    fm.AddRule(New FzAND(TargetClose, AmmoLoads), Undesirable)
    fm.AddRule(New FzAND(TargetClose, AmmoOkay), Undesirable)
    fm.AddRule(New FzAND(TargetClose, AmmoLow), Undesirable)

    fm.AddRule(New FzAND(TargetMedium, AmmoLoads), VeryDesirable)
    fm.AddRule(New FzAND(TargetMedium, AmmoOkay), VeryDesirable)
    fm.AddRule(New FzAND(TargetMedium, AmmoLow), Desirable)

    fm.AddRule(New FzAND(TargetFar, AmmoLoads), Desirable)
    fm.AddRule(New FzAND(TargetFar, New FzFairly(AmmoOkay)), Undesirable)
    'You can even make more complex statements
    'If TargetFar And (AmmoOkay OR Very(AmmoLow)) Then Undesirable
    fm.AddRule(New FzAND(TargetFar, New FzOR(AmmoOkay, New FzVery(AmmoLow))), Undesirable)

    'fuzzify distance and amount of ammo
    fm.Fuzzify("DistToTarget", 60)
    fm.Fuzzify("AmmoStatus", 30)
    'Try MaxAV method
    Local result1:Float = fm.Defuzzify("Desirability", FuzzyModule.DefuzzifyMethod_MaxAv)
    Print result1

'   Print fm.WriteAllDOMs()

    'fuzzify distance and amount of ammo
    fm.Fuzzify("DistToTarget", 60)
    fm.Fuzzify("AmmoStatus", 100)
    'Try MaxAV method
    result1 = fm.Defuzzify("Desirability", FuzzyModule.DefuzzifyMethod_MaxAv)
    Print result1

    fm.Fuzzify("DistToTarget", 60)
    fm.Fuzzify("AmmoStatus", 1)
    'Try MaxAV method
    result1 = fm.Defuzzify("Desirability", FuzzyModule.DefuzzifyMethod_MaxAv)
    Print result1

    Print fm.WriteAllDOMs()

    Return 0
End
