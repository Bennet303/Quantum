// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples.CHSHGame {
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Random;

    /// # Summary
    /// The number of times the classical and quantum strategies have won the CHSH game.
    ///
    /// # Named Items
    /// ## ClassicalWins
    /// The number of times the classical strategy won.
    /// ## QuantumWins
    /// The number of times the quantum strategy won.
    internal newtype Score = (
        ClassicalWins : Int,
        QuantumWins : Int
    );

    /// # Summary
    /// Compares the success rates of the classical and quantum CHSH game strategies across 10,000 trials.
    @EntryPoint()
    operation CompareStrategies() : Unit {
        let nTrials = 10000;

        // Play the CHSH game repeatedly (the number of times is set by nTrials). Each time the
        // PlayGame operation is called, it tries both the classical and quantum strategies and
        // returns the result of both in the Score tuple. The DrawMany operation collects all of
        // these scores into an array.
        let scores = DrawMany(PlayGame, nTrials, ());

        // To compute the total number of wins for each strategy, add up all of the scores in the
        // array by using a fold.
        let total = Fold(PlusScore, Score(0, 0), scores);

        let classicalWinRate = IntAsDouble(total::ClassicalWins) / IntAsDouble(nTrials);
        let quantumWinRate = IntAsDouble(total::QuantumWins) / IntAsDouble(nTrials);
        Message($"Classical success rate: {classicalWinRate}");
        Message($"Quantum success rate: {quantumWinRate}");

        if total::QuantumWins > total::ClassicalWins {
            Message("The quantum success rate exceeded the classical success rate!");
        }
    }

    /// # Summary
    /// Plays one round of the CHSH game for each of the classical and quantum strategies.
    ///
    /// # Output
    /// The score for both strategies (either zero or one win each).
    internal operation PlayGame() : Score {
        let aliceBit = DrawRandomBool(0.5);
        let bobBit = DrawRandomBool(0.5);
        let aliceMeasuresFirst = DrawRandomBool(0.5);

        let classicalXor = not PlayClassicalStrategy(aliceBit, bobBit);
        let quantumXor = not PlayQuantumStrategy(aliceBit, bobBit, aliceMeasuresFirst);

        return Score(
            (aliceBit and bobBit) == classicalXor ? 1 | 0,
            (aliceBit and bobBit) == quantumXor ? 1 | 0
        );
    }

    /// # Summary
    /// Adds two scores.
    ///
    /// # Input
    /// ## score1
    /// The first score.
    /// ## score2
    /// The second score.
    ///
    /// # Output
    /// The sum of the first and second scores.
    internal function PlusScore(score1 : Score, score2 : Score) : Score {
        return Score(
            score1::ClassicalWins + score2::ClassicalWins,
            score1::QuantumWins + score2::QuantumWins
        );
    }
}
