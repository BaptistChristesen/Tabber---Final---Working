import SwiftUI

struct TunerView: View {
    let tunerData: TunerData
    @State var modifierPreference: ModifierPreference
    @State var selectedTransposition: Int

    private var match: ScaleNote.Match {
        tunerData.closestNote.inTransposition(ScaleNote.allCases[selectedTransposition])
    }

    var body: some View {
        VStack(alignment: .noteCenter) {
            Spacer()
            MatchedNoteView(
                match: match,
                modifierPreference: modifierPreference
            )
            Spacer()
        }
    }
}

struct TunerView_Previews: PreviewProvider {
    static var previews: some View {
        TunerView(
            tunerData: TunerData(),
            modifierPreference: .preferSharps,
            selectedTransposition: 0
        )
    }
}
