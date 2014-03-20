Strict
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
    bbdoc: Singleton set
    about:
    This defines a fuzzy set that is a singleton (a range over which the DOM is always 1.0)
#End Rem
Class FuzzySetSingleton Extends FuzzySet
    'the values that define the shape of this FLV
    Field m_dPeakPoint:Float
    Field m_dRightOffset:Float
    Field m_dLeftOffset:Float

    #Rem
        bbdoc: Creates a TFuzzySetSingleton object
    #End Rem
    Method New(peak:Float, leftOffset:Float, rightOffset:Float)
        Super.New(peak)
        Self.m_dPeakPoint = peak
        Self.m_dLeftOffset = leftOffset
        Self.m_dRightOffset = rightOffset
    End Method

    #Rem
        bbdoc: this Method calculates the degree of membership For a particular value
    #End Rem
    Method CalculateDOM:Float(val:Float)
        If (val >= Self.m_dPeakPoint - Self.m_dLeftOffset) And (val <= Self.m_dPeakPoint + Self.m_dRightOffset)
            Return 1.0
        'out of range of this FLV, return zero
        Else
            Return 0.0
        End If
    End Method
End
