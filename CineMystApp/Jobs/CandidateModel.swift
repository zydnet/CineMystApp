import Foundation

struct CandidateModel {
    let name: String
    // If videoURL is provided, use it; otherwise fall back to bundled videoName (without extension)
    let videoURL: URL?
    let videoName: String
    let location: String
    let experience: String

    static let sampleData: [CandidateModel] = [
        .init(name: "Shreya Sharma 26",
              videoURL: nil,
              videoName: "me1",  // video file name without extension
              location: "Mumbai, India",
              experience: "5+ years experience"),

        .init(name: "Aarushi Mehta 24",
              videoURL: nil,
              videoName: "me2",
              location: "Delhi, India",
              experience: "3+ years experience"),

        .init(name: "Priya Kapoor 28",
              videoURL: nil,
              videoName: "me3",
              location: "Bangalore, India",
              experience: "7+ years experience")
    ]
}
