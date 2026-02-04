
import UIKit
import AVFoundation

// MARK: - Reels View Controller
final class ReelsViewController: UIViewController {
    
    private var reels: [Reel] = []
    private var currentIndex: Int = 0
    private var isLoadingMore = false
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isPagingEnabled = true
        cv.showsVerticalScrollIndicator = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .black
        cv.delegate = self
        cv.dataSource = self
        cv.register(ReelCell.self, forCellWithReuseIdentifier: ReelCell.identifier)
        return cv
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCollectionView()
        loadInitialReels()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playCurrentVideo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pauseCurrentVideo()
    }
    
    // MARK: - Setup
    private func setupCollectionView() {
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Data Loading
    private func loadInitialReels() {
        reels = createSampleReels()
        collectionView.reloadData()
    }
    
    private func loadMoreReels() {
        guard !isLoadingMore else { return }
        isLoadingMore = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            let newReels = self.createSampleReels()
            self.reels.append(contentsOf: newReels)
            self.collectionView.reloadData()
            self.isLoadingMore = false
        }
    }
    
    private func createSampleReels() -> [Reel] {
        let sampleAvatar = UIImage(named: "flick") ?? UIImage(systemName: "person.circle.fill")
        
        return [
            Reel(
                videoURL: "me1",
                authorName: "Emily Watson",
                authorAvatar: sampleAvatar,
                likes: "253K",
                comments: "1,139",
                shares: "29",
                audioTitle: "Title · Original audio"
            ),
            Reel(
                videoURL: "me1",
                authorName: "John Smith",
                authorAvatar: sampleAvatar,
                likes: "128K",
                comments: "856",
                shares: "45",
                audioTitle: "Trending · Popular sound"
            ),
            Reel(
                videoURL: "me1",
                authorName: "Sarah Johnson",
                authorAvatar: sampleAvatar,
                likes: "456K",
                comments: "2,341",
                shares: "89",
                audioTitle: "Behind the scenes · Original"
            )
        ]
    }
    
    // MARK: - Video Control
    private func playCurrentVideo() {
        let indexPath = IndexPath(item: currentIndex, section: 0)
        if let cell = collectionView.cellForItem(at: indexPath) as? ReelCell {
            cell.play()
        }
    }
    
    private func pauseCurrentVideo() {
        let indexPath = IndexPath(item: currentIndex, section: 0)
        if let cell = collectionView.cellForItem(at: indexPath) as? ReelCell {
            cell.pause()
        }
    }
    
    private func pauseAllExcept(index: Int) {
        for i in 0..<reels.count where i != index {
            let indexPath = IndexPath(item: i, section: 0)
            if let cell = collectionView.cellForItem(at: indexPath) as? ReelCell {
                cell.pause()
            }
        }
    }
    
    // MARK: - Comment Bottom Sheet
    private func showCommentSheet() {
        let commentVC = CommentBottomSheetViewController()
        commentVC.modalPresentationStyle = .pageSheet
        
        if let sheet = commentVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        
        present(commentVC, animated: true)
    }
    
    // MARK: - Share Bottom Sheet
    private func showShareSheet() {
        let shareVC = ShareBottomSheetViewController()
        shareVC.modalPresentationStyle = .pageSheet
        
        if let sheet = shareVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        
        present(shareVC, animated: true)
    }
}

// MARK: - UICollectionView DataSource
extension ReelsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ReelCell.identifier,
            for: indexPath
        ) as? ReelCell else {
            return UICollectionViewCell()
        }
        
        let reel = reels[indexPath.item]
        cell.configure(with: reel)
        cell.delegate = self
        
        return cell
    }
}

// MARK: - UICollectionView Delegate
extension ReelsViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageHeight = scrollView.frame.height
        let newIndex = Int(scrollView.contentOffset.y / pageHeight)
        
        if newIndex != currentIndex {
            pauseAllExcept(index: newIndex)
            currentIndex = newIndex
            playCurrentVideo()
        }
        
        if currentIndex >= reels.count - 2 {
            loadMoreReels()
        }
    }
}

// MARK: - ReelCell Delegate
extension ReelsViewController: ReelCellDelegate {

    func didTapComment(on cell: ReelCell) {
        // your existing code
    }

    func didTapShare(on cell: ReelCell) {
        // your existing code
    }

    func didTapMore(on cell: ReelCell, sourceView: UIView) {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        sheet.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
            print("Save tapped")
        }))

        sheet.addAction(UIAlertAction(title: "Interested", style: .default, handler: { _ in
            print("Interested tapped")
        }))

        sheet.addAction(UIAlertAction(title: "Not Interested", style: .default, handler: { _ in
            print("Not Interested tapped")
        }))

        sheet.addAction(UIAlertAction(title: "Report", style: .destructive, handler: { _ in
            print("Report tapped")
        }))

        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        // iPad popover support
        if let pop = sheet.popoverPresentationController {
            pop.sourceView = sourceView
            pop.sourceRect = sourceView.bounds
        }

        present(sheet, animated: true)
    }
}

  
