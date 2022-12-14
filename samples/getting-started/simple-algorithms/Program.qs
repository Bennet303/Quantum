// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

//////////////////////////////////////////////////////////////////////////
// Introduction //////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

// This sample contains several simple quantum algorithms coded in Q#. The
// intent is to highlight the expressive capabilities of the language that
// enable it to express quantum algorithms that consist of a short quantum
// part and classical post-processing that is simple, or in some cases,
// trivial.

namespace Microsoft.Quantum.Samples.SimpleAlgorithms {

    open Microsoft.Quantum.Arrays as Array;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Samples.SimpleAlgorithms.HiddenShift;
    open Microsoft.Quantum.Samples.SimpleAlgorithms.DeutschJozsa;
    open Microsoft.Quantum.Samples.SimpleAlgorithms.BernsteinVazirani;

    @EntryPoint()
    operation RunProgram (nQubits : Int) : Unit {

        // Parity Sampling with the BernsteinβVazirani Algorithm:

        // Consider a function π(π₯β) on bitstrings π₯β = (π₯β, β¦, π₯βββ) of the
        // form
        //
        //     π(π₯β) β Ξ£α΅’ π₯α΅’ πα΅’
        //
        // where πβ = (πβ, β¦, πβββ) is an unknown bitstring that determines
        // the parity of π.

        // The BernsteinβVazirani algorithm allows determining π given a
        // quantum operation that implements
        //
        //     |π₯βͺ|π¦βͺ β¦ |π₯βͺ|π¦ β π(π₯)βͺ.
        //
        // In SimpleAlgorithms.qs, we implement this algorithm as the
        // operation RunBernsteinVazirani. This operation takes an
        // integer whose bits describe π, then uses those bits to
        // construct an appropriate operation, and finally measures π.

        // We call that operation here, ensuring that we always get the
        // same value for π that we provided as input.

        for parity in 0 .. (1 <<< nQubits) - 1 {
            let measuredParity = RunBernsteinVazirani(nQubits, parity);
            if (measuredParity != parity) {
                fail $"Measured parity {measuredParity}, but expected {parity}.";
            }
        }

        Message("All parities measured successfully!");

        // Constant versus Balanced Functions with the DeutschβJozsa Algorithm:

        // A Boolean function is a function that maps bitstrings to a
        // bit,
        //
        //     π : {0, 1}^n β {0, 1}.
        //
        // We say that π is constant if π(π₯β) = π(π¦β) for all bitstrings
        // π₯β and π¦β, and that π is balanced if π evaluates to true (1) for
        // exactly half of its inputs.

        // If we are given a function π as a quantum operation π |π₯βͺ|π¦βͺ
        // = |π₯βͺ|π¦ β π(π₯)βͺ, and are promised that π is either constant or
        // is balanced, then the DeutschβJozsa algorithm decides between
        // these cases with a single application of π.

        // In SimpleAlgorithms.qs, we implement this algorithm as
        // RunDeutschJozsa, following the pattern above.
        // This time, however, we will pass an array to Q# indicating
        // which elements of π are marked; that is, should result in true.
        // We check by ensuring that RunDeutschJozsa returns true
        // for constant functions and false for balanced functions.

        let elements = nQubits > 0 ? Array.SequenceI(0, (1 <<< nQubits) - 1) | new Int[0];
        if (RunDeutschJozsa(nQubits, elements[...2...])) {
            fail "Measured that test case {balancedTestCase} was constant!";
        }

        if (not RunDeutschJozsa(nQubits, elements)) {
            fail "Measured that test case {constantTestCase} was balanced!";
        }

        Message("Both constant and balanced functions measured successfully!");

        // Finding Hidden Shifts of Bent Functions with the Roetteler Algorithm:

        // Finally, we consider the case of finding a hidden shift π 
        // between two Boolean functions π(π₯) and π(π₯) = π(π₯ β π ).
        // This problem can be solved on a quantum computer with one call
        // to each of π and π in the special case that both functions are
        // bent; that is, that they are as far from linear as possible.

        // Here, we run the test case HiddenShiftBentCorrelationTestCase
        // defined in the matching Q# source code, and ensure that it
        // correctly finds each hidden shift for a family of bent
        // functions defined by the inner product.

        for shift in 0 .. (1 <<< nQubits) - 1 {
            let measuredShift = RunHiddenShift(shift, nQubits);
            if (measuredShift != shift) {
                fail $"Measured shift {measuredShift}, but expected {shift}.";
            }
        }

        Message("Measured hidden shifts successfully!");
    }
}
