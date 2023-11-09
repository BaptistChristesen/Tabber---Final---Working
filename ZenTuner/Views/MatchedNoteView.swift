import SwiftUI

struct MatchedNoteView: View {
    let match: ScaleNote.Match
    @State var modifierPreference: ModifierPreference

    var body: some View {
        ZStack(alignment: .noteModifier) {
            //find out how to stop the second character from being superscripted, and rather concatenate both
            HStack(alignment: .lastTextBaseline) {
                
                
                
                
                
                /*******************************************************/
                
                //first letter
                
                MainNoteView(note: note)
                    .font(.system(size: 10))
                    .animation(nil, value: note) // Don't animate text frame
                    .animatingPerceptibleForegroundColor(isPerceptible: match.distance.isPerceptible)


                /*******************************************************/
            }

            if let modifier = modifier {
                Text(modifier)
                    // TODO: Avoid hardcoding size
                    .font(.system(size: 30, design: .rounded))
                    .animatingPerceptibleForegroundColor(isPerceptible: match.distance.isPerceptible)
                    //.alignmentGuide(.octaveCenter) { dimensions in
                      //  dimensions[HorizontalAlignment.center]
                    //}
            }
        }
        .animation(.easeInOut, value: match.distance.isPerceptible)
        .onTapGesture {
            modifierPreference = modifierPreference.toggled
        }
    }

    private var preferredName: String {
        switch modifierPreference {
        case .preferSharps:
            match.note.names
        case .preferFlats:
            match.note.names
        }
    }

    private var note: String {
        String(preferredName)
    }

    private var modifier: String? {
        //preferredName.count > 1
            //String(preferredName.suffix(1)) :
            nil
    }
}

private extension View {
    @ViewBuilder
    func animatingPerceptibleForegroundColor(isPerceptible: Bool) -> some View {
        self
            .foregroundColor(isPerceptible ? .perceptibleMusicalDistance : .imperceptibleMusicalDistance)
    }
}

struct MatchedNoteView_Previews: PreviewProvider {
    static var previews: some View {
        MatchedNoteView(
            match: ScaleNote.Match(
                note: .AS,
                octave: 4,
                distance: 0
            ),
            modifierPreference: .preferSharps
        )
        .previewLayout(.sizeThatFits)
    }
}
