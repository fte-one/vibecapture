import Foundation

/// The wording of the prompt a feedback session produces, in the app's language.
struct PromptText: Equatable {
    let languageName: String
    let image: String
    let recorded: String
    let attachedLine: String
    let folderLine: String
    /// How both screenshots lines end, so the legend after it can be kept when switching.
    let markerEnd: String
    let legend: String
    let tasks: String
    let pageItem: String
    let imagesItem: String
    let quoteItem: String
    let quoted: String
    let questions: String
    let extra: String
    let imagesAndSpeech: String
    let fileLine: String
    let selectedLine: String
    let afterLast: String
    let nothingSaid: String
    let transcript: String
    let nothingTranscribed: String
    let visited: String

    static let english = PromptText(
        languageName: "English",
        image: "Image",
        recorded: "> Recorded on %@ · %@ min · %@",
        attachedLine: "> The %d screenshots are attached to this message as images, in order Image 1 to Image %d; the number is also in the top left of each image. ",
        folderLine: "> Screenshots in the folder `%@`: Image N is `NN.png`, the number is in the top left of each image. ",
        markerEnd: "top left of each image. ",
        legend: "Red lines are my own drawings to show the spot I mean; red circles are clicks, yellow circles show where the mouse pointed while I was talking, red frames are selected areas. Look at the images before you change anything.",
        tasks: "## Tasks",
        pageItem: "- Page: ",
        imagesItem: "- Images: ",
        quoteItem: "- Quote: ",
        quoted: "“%@”",
        questions: "## Open questions",
        extra: "## Additional instructions",
        imagesAndSpeech: "## Images and what was said",
        fileLine: "File: ",
        selectedLine: "Selected: ",
        afterLast: "### After the last image",
        nothingSaid: "(nothing said)",
        transcript: "## Transcript",
        nothingTranscribed: "- (Nothing said or nothing transcribed.)",
        visited: "## Pages visited")

    static let german = PromptText(
        languageName: "German",
        image: "Bild",
        recorded: "> Aufgenommen am %@ · %@ Min. · %@",
        attachedLine: "> Die %d Screenshots hängen dieser Nachricht als Bilder an, in der Reihenfolge Bild 1 bis Bild %d; die Nummer steht zusätzlich oben links im Bild. ",
        folderLine: "> Screenshots im Ordner `%@`: Bild N ist `NN.png`, die Nummer steht oben links im Bild. ",
        markerEnd: "oben links im Bild. ",
        legend: "Rote Linien habe ich selbst gezogen, um die gemeinte Stelle zu zeigen; rote Kreise sind Klicks, gelbe Kreise zeigen, wohin die Maus beim Sprechen zeigte, rote Rahmen sind markierte Bereiche. Sieh dir die Bilder an, bevor du etwas änderst.",
        tasks: "## Aufgaben",
        pageItem: "- Seite: ",
        imagesItem: "- Bilder: ",
        quoteItem: "- O-Ton: ",
        quoted: "„%@“",
        questions: "## Offene Fragen",
        extra: "## Zusatzanweisungen",
        imagesAndSpeech: "## Bilder und was dazu gesagt wurde",
        fileLine: "Datei: ",
        selectedLine: "Markiert: ",
        afterLast: "### Nach dem letzten Bild",
        nothingSaid: "(nichts gesagt)",
        transcript: "## Protokoll",
        nothingTranscribed: "- (Nichts gesagt oder nicht in Text umgewandelt.)",
        visited: "## Besuchte Seiten")

    static let all = [english, german]

    /// The prompt follows the language the app runs in.
    @MainActor
    static var current: PromptText { AppLanguage.active == .de ? german : english }

    func isScreenshotsLine(_ line: String) -> Bool {
        line.hasPrefix(">") && line.contains(markerEnd)
    }
}
