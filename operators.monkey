Strict
Import monkey.list
Import monkey.math
Import term
Import fzset
#Rem
    Copyright (c) 2010-2014 Christiaan Kras

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
#End Rem

#Rem
    bbdoc: a fuzzy AND operator type
    about: Type to provider the fuzzy AND operator to be used in the creation of a fuzzy rule base
#End Rem
Class FzAND Extends FuzzyTerm
    'an instance of this class may AND together up to 4 terms
    Field m_Terms:List<FuzzyTerm> = New List<FuzzyTerm>

    #Rem
        bbdoc:Creates AND operator
    #End Rem
    Method New(ops:FuzzyTerm[])
        For Local op:FuzzyTerm = EachIn ops
            Self.m_Terms.AddLast(op.Clone())
        Next
    End Method

    Method New(op1:FuzzyTerm, op2:FuzzyTerm, op3:FuzzyTerm = Null, op4:FuzzyTerm = Null)
        Self.m_Terms.AddLast(op1.Clone())
        Self.m_Terms.AddLast(op2.Clone())
        If op3 <> Null Then Self.m_Terms.AddLast(op3.Clone())
        If op4 <> Null Then Self.m_Terms.AddLast(op4.Clone())
    End

    #Rem
        bbdoc: Clones AND operator
    #End Rem
    Method Clone:FuzzyTerm()
        Local term:FzAND = New FzAND(Self.m_Terms.ToArray())
        Return term
    End Method

    #Rem
        bbdoc: the AND operator returns the minimum DOM of the sets it is operating on
    #End Rem
    Method GetDOM:Float()
        Local smallest:Float = Pow(10, 308)
        For Local curTerm:FuzzyTerm = EachIn Self.m_Terms
            If curTerm.GetDOM() < smallest
                smallest = curTerm.GetDOM()
            End If
        Next
        Return smallest
    End Method

    #Rem
        bbdoc: Clears DOM
    #End Rem
    Method ClearDOM:Void()
        For Local curTerm:FuzzyTerm = EachIn Self.m_Terms
            curTerm.ClearDOM()
        Next
    End Method

    #Rem
        bbdoc:
    #End Rem
    Method ORwithDOM:Void(val:Float)
        For Local curTerm:FuzzyTerm = EachIn Self.m_Terms
            curTerm.ORwithDOM(val)
        Next
    End Method
End


#Rem
    bbdoc: a fuzzy OR operator type
    about: Type to provider the fuzzy OR operator to be used in the creation of a fuzzy rule base
#End Rem
Class FzOR Extends FuzzyTerm
    'an instance of this class may OR together up to 4 terms
    Field m_Terms:List<FuzzyTerm> = New List<FuzzyTerm>

    #Rem
        bbdoc:
    #End Rem
    Method New(ops:FuzzyTerm[])
        For Local op:FuzzyTerm = EachIn ops
            Self.m_Terms.AddLast(op.Clone())
        Next
    End Method

    Method New(op1:FuzzyTerm, op2:FuzzyTerm, op3:FuzzyTerm = Null, op4:FuzzyTerm = Null)
        Self.m_Terms.AddLast(op1.Clone())
        Self.m_Terms.AddLast(op2.Clone())
        If op3 <> Null Then Self.m_Terms.AddLast(op3.Clone())
        If op4 <> Null Then Self.m_Terms.AddLast(op4.Clone())
    End

    #Rem
        bbdoc: Clones OR operator
    #End Rem
    Method Clone:FuzzyTerm()
        Local term:FzOR = New FzOR(Self.m_Terms.ToArray())
        Return term
    End Method

    #Rem
        bbdoc: the OR operator returns the maximum DOM of the sets it is operating on
    #End Rem
    Method GetDOM:Float()
        Local largest:Float = -(Pow(10, -38))
        For Local curTerm:FuzzyTerm = EachIn Self.m_Terms
            If curTerm.GetDOM() > largest
                largest = curTerm.GetDOM()
            End If
        Next
        Return largest
    End Method

    #Rem
        bbdoc: Clears DOM
    #End Rem
    Method ClearDOM:Void()
        'Assert 0, "TFzOr.ClearDOM: invalid context"
    End Method

    #Rem
        bbdoc:
    #End Rem
    Method ORwithDOM:Void(val:Float)
        'Assert 0, "TFzOr.ORwithDOM: invalid context"
    End
End

