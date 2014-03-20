Strict
Import term
Import set
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
    bbdoc: class to provide a proxy for a fuzzy set. The proxy inherits from FuzzyTerm and therefore can be used to create fuzzy rules
#End Rem
Class FzSet Extends FuzzyTerm
    'a reference to the fuzzy set this proxy represents
    Field m_Set:FuzzySet

    #Rem
        bbdoc: Create a TFzSet
    #End Rem
    Method New(fs:FuzzySet)
        Self.m_Set = fs
    End Method

    #Rem
        bbdoc: Clone a TFzSet
    #End Rem
    Method Clone:FuzzyTerm()
        Return New FzSet(Self.m_Set)
    End Method

    #Rem
        bbdoc: Returns DOM
    #End Rem
    Method GetDOM:Float()
        Return Self.m_Set.GetDOM()
    End Method

    #Rem
        bbdoc: Clears DOM
    #End Rem
    Method ClearDOM:Void()
        Self.m_Set.ClearDOM()
    End Method

    #Rem
        bbdoc:
    #End Rem
    Method ORwithDOM:Void(val:Float)
        Self.m_Set.ORwithDOM(val)
    End Method
End
