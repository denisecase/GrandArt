import SwiftUI
import UniformTypeIdentifiers

@available(macOS 12.0, *)
struct TabSave: View {
  @ObservedObject var doc: GrandArtDocument
  @ObservedObject var popupManager = PopupManager()
  @Binding var requiresFullCalc: Bool
  @Binding var showGradient: Bool

  var body: some View {
    ScrollView {
      VStack {
        Section(
          header:
          Text("Save Your Art")
            .font(.headline)
            .fontWeight(.medium)
            .padding(.bottom)
        ) {
          
          Button("Save Picture Inputs (as data file)") {
            doc.saveGrandArtImageInputs()
          }
          .help("Save GrandArt picture inputs as .grandart.")
          
          Button("Save Picture (as .png)") {
            doc.saveGrandArtImage()
          }
          .help("Save GrandArt picture as .png.")

        } // end section
      } //  vstack
    } // scroll
    .onAppear {
      requiresFullCalc = false
      showGradient = false
    }
    .onDisappear {
      if requiresFullCalc {
        requiresFullCalc = false
      }
    }
  }
}
