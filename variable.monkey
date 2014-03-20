Strict
Import monkey.list
Import monkey.map
Import monkey.math

Import set
Import fzset
Import setleftshoulder
Import setrightshoulder
Import setsingleton
Import settriangle

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
    bbdoc: Class to define a fuzzy linguistic variable (FLV).
    about: An FLV comprises of a number of fuzzy sets
#End Rem
Class FuzzyVariable
    Field m_MemberSets:StringMap<FuzzySet>
    'the minimum and maximum value of the range of this variable
    Field m_dMinRange:Float
    Field m_dMaxRange:Float

    #Rem
        bbdoc: Initializes fuzzy variable
    #End Rem
    Method New()
        Self.m_dMinRange = 0.0
        Self.m_dMaxRange = 0.0
        Self.m_MemberSets = New StringMap<FuzzySet>
    End

    #Rem
        bbdoc: this method is called with the upper and lower bound of a set each time a new set is added to adjust the upper and lower range values accordingly
    #End Rem
    Method AdjustRangeToFit:Void(minBound:Float, maxBound:Float)
        If minBound < Self.m_dMinRange Then Self.m_dMinRange = minBound
        If maxBound > Self.m_dMaxRange Then Self.m_dMaxRange = maxBound
    End

    'the following methods create instances of the sets named in the method
    'name and add them to the member set map. Each time a set of any type is
    'added the m_dMinRange and m_dMaxRange are adjusted accordingly. All of the
    'methods return a proxy class representing the newly created instance. This
    'proxy set can be used as an operand when creating the rule base.

    #Rem
        bbdoc: adds a left shoulder type set
    #End Rem
    Method AddLeftShoulderSet:FzSet(name:String, minBound:Float, peak:Float, maxBound:Float)
        Local set:FuzzySetLeftShoulder = New FuzzySetLeftShoulder(peak, peak - minBound, maxBound - peak)
        Self.m_MemberSets.Insert(name, set)

        Self.AdjustRangeToFit(minBound, maxBound)

        Return New FzSet(set)
    End Method

    #Rem
        bbdoc: adds a right shoulder type set
    #End Rem
    Method AddRightShoulderSet:FzSet(name:String, minBound:Float, peak:Float, maxBound:Float)
        Local set:FuzzySetRightShoulder = New FuzzySetRightShoulder(peak, peak - minBound, maxBound - peak)
        Self.m_MemberSets.Insert(name, set)

        Self.AdjustRangeToFit(minBound, maxBound)

        Return New FzSet(set)
    End Method

    #Rem
        bbdoc: adds a triangular shaped fuzzy set to the variable
    #End Rem
    Method AddTriangularSet:FzSet(name:String, minBound:Float, peak:Float, maxBound:Float)
        Local set:FuzzySetTriangle = New FuzzySetTriangle(peak, peak - minBound, maxBound - peak)
        Self.m_MemberSets.Insert(name, set)

        Self.AdjustRangeToFit(minBound, maxBound)

        Return New FzSet(set)
    End Method

    #Rem
        bbdoc: adds a singleton To the variable
    #End Rem
    Method AddSingletonSet:FzSet(name:String, minBound:Float, peak:Float, maxBound:Float)
        Local set:FuzzySetSingleton = New FuzzySetSingleton(peak, peak - minBound, maxBound - peak)
        Self.m_MemberSets.Insert(name, set)

        Self.AdjustRangeToFit(minBound, maxBound)

        Return New FzSet(set)
    End Method

    #Rem
        bbdoc: takes a crisp value and calculates its degree of membership for each set in the variable
    #End Rem
    Method Fuzzify:Void(val:Float)
        'Assert (val >= Self.m_dMinRange And val <= Self.m_dMaxRange), "TFuzzyVariable.Fuzzify: value out of range"
        'for each set in the flv calculate the DOM for the given value
        For Local curSet:FuzzySet = EachIn Self.m_MemberSets.Values()
            curSet.SetDOM(curSet.CalculateDOM(val))
        Next
    End Method

    #Rem
        bbdoc: defuzzifies the value by averaging the maxima of the sets that have fired
        about: OUTPUT = sum (maxima * DOM) / sum (DOMs) 
    #End Rem
    Method DeFuzzifyMaxAv:Float()
        Local bottom:Float = 0.0
        Local top:Float = 0.0

        For Local curSet:FuzzySet = EachIn Self.m_MemberSets.Values()
            bottom+=curSet.GetDOM()
            top+=curSet.GetRepresentativeVal() * curSet.GetDOM()
        Next

        If bottom = 0
            Return 0.0
        End If

        Return top / bottom;
    End Method

    #Rem
        bbdoc: defuzzify the variable using the centroid method
    #End Rem
    Method DeFuzzifyCentroid:Float(numSamples:Int)
        'calculate the step size
        Local stepSize:Float = (Self.m_dMaxRange - Self.m_dMinRange) / Float(numSamples)

        Local totalArea:Float = 0.0
        Local sumOfMoments:Float = 0.0

        'step through the range of this variable in increments equal to StepSize
        'adding up the contribution (lower of CalculateDOM or the actual DOM of this
        'variable's fuzzified value) for each subset. This gives an approximation of
        'the total area of the fuzzy manifold.(This is similar to how the area under
        'a curve is calculated using calculus... the heights of lots of 'slices' are
        'summed to give the total area.)

        'in addition the moment of each slice is calculated and summed. Dividing
        'the total area by the sum of the moments gives the centroid. (Just like
        'calculating the center of mass of an object)
        For Local samp:Int = 1 To numSamples
            'for each set get the contribution to the area. This is the lower of the 
            'value returned from CalculateDOM or the actual DOM of the fuzzified 
            'value itself
            For Local curSet:FuzzySet = EachIn Self.m_MemberSets.Values()
                Local contribution:Float = Min(curSet.CalculateDOM(Self.m_dMinRange + samp * stepSize), curSet.GetDOM())
                totalArea+=contribution
                sumOfMoments+=(Self.m_dMinRange + samp * stepSize) * contribution
            Next
        Next

        If totalArea = 0
            Return 0.0
        End If

        Return sumOfMoments / totalArea
    End Method

    #Rem
        bbdoc: Used for debugging
    #End Rem
    Method WriteDOMs:String()
        Local stream:String
        For Local key:String = EachIn Self.m_MemberSets.Keys()
            stream+="~n" + key + " is " + FuzzySet(Self.m_MemberSets.ValueForKey(key)).GetDOM()
        Next

        stream+="~nMin Range: " + Self.m_dMinRange + "~nMax Range: " + Self.m_dMaxRange

        Return stream
    End Method
End
