struct CandidateModel {
    let name: String
    let videoName: String  // Changed from imageName
    let location: String
    let experience: String

    static let sampleData: [CandidateModel] = [
        .init(name: "Shreya Sharma 26",
              videoName: "me1",  // video file name without extension
              location: "Mumbai, India",
              experience: "5+ years experience"),

        .init(name: "Aarushi Mehta 24",
              videoName: "me2",
              location: "Delhi, India",
              experience: "3+ years experience"),

        .init(name: "Priya Kapoor 28",
              videoName: "me3",
              location: "Bangalore, India",
              experience: "7+ years experience")
    ]
}
