import Darwin.C.math
import SwiftUI
/// A note in a twelve-tone equal temperament scale. https://en.wikipedia.org/wiki/Equal_temperament
enum ScaleNote: Int, CaseIterable, Identifiable {
    case C, CS, D, DS, E, F, FS, G, GS, A, AS, B
    var id: Int { rawValue }
    /// A note match given an input frequency.
    struct Match: Hashable {
        /// The matched note.
        let note: ScaleNote
        /// The octave of the matched note.
        let octave: Int
        /// The distance between the input frequency and the matched note's defined frequency.
        let distance: Frequency.MusicalDistance
        /// The frequency of the matched note, adjusted by octave.
        var frequency: Frequency { note.frequency.shifted(byOctaves: octave) }
        /// The current note match adjusted for transpositions.
        ///
        /// - parameter transposition: The transposition on which to map the current match.
        ///
        /// - returns: The match mapped to the specified transposition.
        func inTransposition(_ transposition: ScaleNote) -> ScaleNote.Match {
            let transpositionDistanceFromC = transposition.rawValue
            guard transpositionDistanceFromC > 0 else {
                return self
            }
            let currentNoteIndex = note.rawValue
            let allNotes = ScaleNote.allCases
            let noteOffset = (allNotes.count - transpositionDistanceFromC) + currentNoteIndex
            let transposedNoteIndex = noteOffset % allNotes.count
            let transposedNote = allNotes[transposedNoteIndex]
            let octaveShift = (noteOffset > allNotes.count - 1) ? 1 : 0
            return ScaleNote.Match(
                note: transposedNote,
                octave: octave + octaveShift,
                distance: distance
            )
        }
    }
    /// Find the closest note to the specified frequency.
    ///
    /// - parameter frequency: The frequency to match against.
    ///
    /// - returns: The closest note match.
    static func closestNote(to frequency: Frequency) -> Match {
        // Shift frequency octave to be within range of scale note frequencies.
        var octaveShiftedFrequency = frequency
        while octaveShiftedFrequency > allCases.last!.frequency {
            octaveShiftedFrequency.shift(byOctaves: -1)
        }
        while octaveShiftedFrequency < allCases.first!.frequency {
            octaveShiftedFrequency.shift(byOctaves: 1)
        }
        // Find closest note
        let closestNote = allCases.min(by: { note1, note2 in
            fabsf(note1.frequency.distance(to: octaveShiftedFrequency).cents) <
                fabsf(note2.frequency.distance(to: octaveShiftedFrequency).cents)
        })!
        let octave = max(octaveShiftedFrequency.distanceInOctaves(to: frequency), 0)
        let fastResult = Match(
            note: closestNote,
            octave: octave,
            distance: closestNote.frequency.distance(to: octaveShiftedFrequency)
        )
         //Fast result can be incorrect at the scale boundary
        guard fastResult.note == .C && fastResult.distance.isFlat ||
                fastResult.note == .B && fastResult.distance.isSharp else
        {
            return fastResult
        }
        var match: Match?
        for octave in [octave, octave + 1] {
            for note in [ScaleNote.C, .B] {
                let distance = note.frequency.shifted(byOctaves: octave).distance(to: frequency)
                if let match = match, abs(distance.cents) > abs(match.distance.cents) {
                    return match
                } else {
                    match = Match(
                        note: note,
                        octave: octave,
                        distance: distance
                    )
                }
            }
        }
        assertionFailure("Closest note could not be found")
        return fastResult
    }
    /// The names for this note.
    //ok so like i gotta make these JUST strongs and then basically i gotta change iot from note names to the tabs
    var names: String {
        switch self {
        case .E:
            "-\n-\n-\n2\n2\n0"
        case .F:
            "-\n-\n-\n3\n3\n1"
        case .FS:
            "-\n-\n-\n4\n4\n2"
        case .G:
            "-\n-\n-\n5\n5\n3"
        case .GS:
            "-\n-\n-\n6\n6\n4"
        case .A:
            "-\n-\n-\n7\n7\n5"
        case .AS:
            "-\n-\n-\n8\n8\n6"
        case .B:
            "-\n-\n-\n9\n9\n7"
        case .C:
            "-\n-\n-\n10\n10\n8"
        case .CS:
            "-\n-\n-\n11\n11\n9"
        case .D:
            "-\n-\n-\n12\n12\n10"
        case .DS:
            "-\n-\n-\n13\n13\n11"
        }
    }
    /// The frequency for this note at the 0th octave in standard pitch: https://en.wikipedia.org/wiki/Standard_pitch
    var frequency: Frequency {
        switch self {
        case .C:            16.35160
        case .CS: 17.32391
        case .D:            18.35405
        case .DS: 19.44544
        case .E:            20.60172
        case .F:            21.82676
        case .FS: 23.12465
        case .G:            24.49971
        case .GS: 25.95654
        case .A:            27.5
        case .AS: 29.13524
        case .B:            30.86771
        }
    }
}
