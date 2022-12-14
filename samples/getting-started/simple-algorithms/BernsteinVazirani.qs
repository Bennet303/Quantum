// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.


// First, note that every Q# function, operation and UDTs (newtypes) must have
// a namespace. We define a new one for this purpose.
namespace Microsoft.Quantum.Samples.SimpleAlgorithms.BernsteinVazirani {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Convert;

    //////////////////////////////////////////////////////////////////////////
    // BernsteinβVazirani Fourier Sampling Quantum Algorithm //////////////////
    //////////////////////////////////////////////////////////////////////////

    /// # Summary
    /// LearnParityViaFourierSampling implements the Bernstein-Vazirani quantum algorithm.
    /// This algorithm computes for a given Boolean function that is promised to be
    /// a parity π(π₯β, β¦, π₯βββ) = Ξ£α΅’ πα΅’ π₯α΅’ a result in form of
    /// a bit vector (πβ, β¦, πβββ) corresponding to the parity function.
    /// Note that it is promised that the function is actually a parity function.
    ///
    /// # Input
    /// ## Uf
    /// A quantum operation that implements |π₯βͺ|π¦βͺ β¦ |π₯βͺ|π¦ β π(π₯)βͺ,
    /// where π is a Boolean function that implements a parity Ξ£α΅’ πα΅’ π₯α΅’.
    /// ## n
    /// The number of bits of the input register |π₯βͺ.
    ///
    /// # Output
    /// An array of type `Bool[]` that contains the parity πβ = (πβ, β¦, πβββ).
    ///
    /// # See Also
    /// - For details see Section 1.4.3 of Nielsen & Chuang.
    ///
    /// # References
    /// - [ *Ethan Bernstein and Umesh Vazirani*,
    ///     SIAM J. Comput., 26(5), 1411β1473, 1997 ](https://doi.org/10.1137/S0097539796300921)
    operation LearnParityViaFourierSampling(Uf : ((Qubit[], Qubit) => Unit), n : Int) : Bool[] {
        // Now, we allocate n + 1 clean qubits. Note that the function Uf is defined
        // on inputs of the form (x, y), where x has n bits and y has 1 bit.
        use queryRegister = Qubit[n];
        use target = Qubit();

        // The last qubit needs to be flipped so that the function will
        // actually be computed into the phase when Uf is applied.
        X(target);

        within {
            // Now, a Hadamard transform is applied to each of the qubits.
            // As the last step before the measurement, a Hadamard transform is
            // applied to all qubits except last one. We could apply the transform to
            // the last qubit also, but this would not affect the final outcome.
            // We use a within-apply block to ensure that the Hadamard transform is
            // correctly inverted.
            ApplyToEachA(H, queryRegister);
        } apply {
            H(target);
            // We now apply Uf to the n+1 qubits, computing |x, yβͺ β¦ |x, y β f(x)βͺ.
            Uf(queryRegister, target);
        }

        // The following for-loop measures all qubits and resets them to
        // zero so that they can be safely returned at the end of the
        // using-block.
        let resultArray = ForEach(MResetZ, queryRegister);

        // The result is already contained in resultArray so no further
        // post-processing is necessary.
        Message($"measured: {resultArray}");

        // Finally, the last qubit, which held the y-register, is reset.
        Reset(target);
        return ResultArrayAsBoolArray(resultArray);
    }


    // To demonstrate the BernsteinβVazirani algorithm, we define
    // a function which returns black-box operations (Qubit[] => ()) of
    // the form

    //    U_f |π₯βͺ|π¦βͺ = |π₯βͺ|π¦ β π(π₯)βͺ,

    // as described above.

    // In particular, we define π by providing the pattern πβ. Thus, we can
    // easily assert that the pattern measured by the BernsteinβVazirani
    // algorithm matches the pattern we used to define π.

    // As is idiomatic in Q#, we define an operation that we will typically
    // only call by partially applying it from within a matching function.
    // To indicate that we are using this idiom, we name the operation
    // with an initial underscore to mark it as private, and provide
    // documentation comments for the function itself.
    internal operation ParityOperationImpl(pattern : Bool[], queryRegister : Qubit[], target : Qubit) : Unit {
        if (Length(queryRegister) != Length(pattern)) {
            fail "Length of input register must be equal to the pattern length.";
        }

        for (patternBit, controlQubit) in Zipped(pattern, queryRegister) {
            if (patternBit) {
                Controlled X([controlQubit], target);
            }
        }
    }


    /// # Summary
    /// Given a bitstring πβ = (rβ, β¦, rβββ), returns an operation implementing
    /// a unitary π that acts on π + 1 qubits as
    ///
    ///       π |π₯βͺ|π¦βͺ = |π₯βͺ|π¦ β π(π₯)βͺ,
    /// where π(π₯) = Ξ£α΅’ π₯α΅’ πα΅’ mod 2.
    ///
    /// # Input
    /// ## pattern
    /// The bitstring πβ used to define the function π.
    ///
    /// # Output
    /// An operation implementing π.
    function ParityOperation(pattern : Bool[]) : ((Qubit[], Qubit) => Unit) {
        return ParityOperationImpl(pattern, _, _);
    }


    // For convenience, we provide an additional operation with a signature
    // that's easy to call from C#. In particular, we define our new operation
    // to take an Int as input and to return an Int as output, where each
    // Int represents a bitstring using the little endian convention.
    operation RunBernsteinVazirani (nQubits : Int, patternInt : Int) : Int {
        let pattern = IntAsBoolArray(patternInt, nQubits);
        let result = LearnParityViaFourierSampling(ParityOperation(pattern), nQubits);
        return BoolArrayAsInt(result);
    }
}
