//
//  BecomeMentorViewController+Areas.swift
//  ProgrammaticMentorship
//

import UIKit
import PhotosUI

// MARK: - BecomeMentorViewController
final class BecomeMentorViewController: UITableViewController {

    // MARK: - Form Model
    private struct Form {
        var fullName: String?
        var professionalTitle: String?
        var about: String?
        var years: String?
        var organisation: String?
        var city: String?
        var country: String?
        var mentorshipAreas: [String: String] = [:]
        var languages: String?
        var avatarImage: UIImage?
        var slots: [Date] = []
    }

    private var form = Form()

    // MARK: - UI Identifiers
    private enum ID {
        static let textField = "TextFieldCell"
        static let textView = "TextViewCell"
        static let button = "ButtonCell"
        static let picker = "PickerCell"
        static let avatar = "AvatarCell"
    }

    private enum Section: Int, CaseIterable {
        case basicInfo = 0, location, expertise, availability, attach
    }

    // MARK: - Submit Button
    private lazy var submitButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Submit", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = UIColor(red: 0x43/255, green: 0x16/255, blue: 0x31/255, alpha: 1)
        b.layer.cornerRadius = 12
        b.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        b.addTarget(self, action: #selector(didTapSubmit), for: .touchUpInside)
        return b
    }()

    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Become a Mentor"
        navigationItem.largeTitleDisplayMode = .never

        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: ID.textField)
        tableView.register(TextViewCell.self, forCellReuseIdentifier: ID.textView)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ID.button)
        tableView.register(PickerCell.self, forCellReuseIdentifier: ID.picker)
        tableView.register(AvatarCell.self, forCellReuseIdentifier: ID.avatar)

        tableView.estimatedRowHeight = 60
        tableView.keyboardDismissMode = .interactive

        let footer = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 96))
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        footer.addSubview(submitButton)

        NSLayoutConstraint.activate([
            submitButton.leadingAnchor.constraint(equalTo: footer.layoutMarginsGuide.leadingAnchor),
            submitButton.trailingAnchor.constraint(equalTo: footer.layoutMarginsGuide.trailingAnchor),
            submitButton.centerYAnchor.constraint(equalTo: footer.centerYAnchor),
            submitButton.heightAnchor.constraint(equalToConstant: 52)
        ])

        tableView.tableFooterView = footer
    }

    // MARK: - Sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section)! {
        case .basicInfo: return "Basic Information"
        case .location: return "Location"
        case .expertise: return "Professional Expertise"
        case .availability: return "Your Availability"
        case .attach: return "Attach Picture"
        }
    }

    // MARK: - Row Count
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .basicInfo: return 5
        case .location: return 2
        case .expertise: return 1 + form.mentorshipAreas.count
        case .availability: return 1 + form.slots.count
        case .attach: return 1
        }
    }

    // MARK: - Cell Creation
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch Section(rawValue: indexPath.section)! {

        // ----------------------
        // BASIC INFO
        // ----------------------
        case .basicInfo:
            switch indexPath.row {

            case 0:
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: ID.textField,
                    for: indexPath
                ) as! TextFieldCell
                cell.configure(placeholder: "Full name",
                               text: form.fullName) { self.form.fullName = $0 }
                return cell

            case 1:
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: ID.textField,
                    for: indexPath
                ) as! TextFieldCell
                cell.configure(placeholder: "Professional title",
                               text: form.professionalTitle) { self.form.professionalTitle = $0 }
                return cell

            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: ID.textField, for: indexPath) as! TextFieldCell
                cell.configure(placeholder: "About you", text: form.about) { self.form.about = $0 }
                return cell


            case 3:
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: ID.button,
                    for: indexPath)
                var config = cell.defaultContentConfiguration()
                config.text = form.years ?? "Experience"
                config.textProperties.color = .systemBlue
                cell.contentConfiguration = config
                cell.accessoryType = .disclosureIndicator
                return cell

            case 4:
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: ID.textField,
                    for: indexPath
                ) as! TextFieldCell
                cell.configure(placeholder: "Organisation",
                               text: form.organisation) { self.form.organisation = $0 }
                return cell

            default:
                return UITableViewCell()
            }

        // ----------------------
        // LOCATION
        // ----------------------
        case .location:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ID.textField,
                for: indexPath
            ) as! TextFieldCell

            if indexPath.row == 0 {
                cell.configure(placeholder: "City", text: form.city) {
                    self.form.city = $0
                }
            } else {
                cell.configure(placeholder: "Country", text: form.country) {
                    self.form.country = $0
                }
            }
            return cell

        // ----------------------
        // EXPERTISE
        // ----------------------
        case .expertise:

            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: ID.button,
                    for: indexPath
                )
                var config = cell.defaultContentConfiguration()
                config.text = "Select Mentorship Area(s)"
                config.secondaryText = form.mentorshipAreas.isEmpty
                    ? "No areas selected"
                    : "\(form.mentorshipAreas.count) selected"
                config.textProperties.color = .systemBlue
                cell.contentConfiguration = config
                return cell
            }

            let areaIndex = indexPath.row - 1
            let area = Array(form.mentorshipAreas.keys.sorted())[areaIndex]
            let price = form.mentorshipAreas[area] ?? "Set price"

            let cell = tableView.dequeueReusableCell(
                withIdentifier: ID.button,
                for: indexPath
            )
            var config = cell.defaultContentConfiguration()
            config.text = area
            config.secondaryText = price
            cell.contentConfiguration = config
            cell.accessoryType = .disclosureIndicator
            return cell

        // ----------------------
        // AVAILABILITY
        // ----------------------
        case .availability:

            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: ID.button,
                    for: indexPath
                )
                var config = cell.defaultContentConfiguration()
                config.text = "Add Slot"
                config.textProperties.color = .systemBlue
                cell.contentConfiguration = config
                return cell
            }

            let idx = indexPath.row - 1
            let slotDate = form.slots[idx]

            let cell = tableView.dequeueReusableCell(
                withIdentifier: ID.button,
                for: indexPath
            )

            var config = cell.defaultContentConfiguration()
            config.text = formattedSlot(slotDate)
            config.textProperties.color = .label
            cell.selectionStyle = .none
            cell.contentConfiguration = config
            return cell

        // ----------------------
        // ATTACH AVATAR
        // ----------------------
        case .attach:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ID.avatar,
                for: indexPath
            ) as! AvatarCell

            cell.configure(image: form.avatarImage) { [weak self] in
                self?.presentPhotoPicker()
            }
            return cell
        }
    }

    // MARK: - Row Selection
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)


        switch Section(rawValue: indexPath.section)! {
        case .basicInfo:
            if indexPath.row == 3 { presentYearsActionSheet() }

        case .expertise:
            if indexPath.row == 0 {
                presentAreaSelector()
            } else {
                let areaIndex = indexPath.row - 1
                let area = Array(form.mentorshipAreas.keys.sorted())[areaIndex]
                presentPriceSelector(for: area)
            }

        case .availability:
            if indexPath.row == 0 {
                presentAddSlot()
            }

        case .attach:
            presentPhotoPicker()

        default: break
        }
    }

    // MARK: - Swipe to Delete (Area + Slots)
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {

        guard editingStyle == .delete else { return }

        switch Section(rawValue: indexPath.section)! {

        case .availability:
            if indexPath.row > 0 {
                let idx = indexPath.row - 1
                form.slots.remove(at: idx)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }

        case .expertise:
            if indexPath.row > 0 {
                let idx = indexPath.row - 1
                let key = Array(form.mentorshipAreas.keys.sorted())[idx]
                form.mentorshipAreas.removeValue(forKey: key)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }

        default: break
        }
    }

    override func tableView(_ tableView: UITableView,
                            editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {

        let sec = Section(rawValue: indexPath.section)!

        if (sec == .availability && indexPath.row > 0)
            || (sec == .expertise && indexPath.row > 0) {
            return .delete
        }
        return .none
    }

    // MARK: - Add Slot Sheet
    private func presentAddSlot() {
        let vc = AddSlotViewController()
        vc.completion = { [weak self] date in
            guard let self = self else { return }

            if !self.form.slots.contains(where: {
                Calendar.current.isDate($0, equalTo: date, toGranularity: .minute)
            }) {
                self.form.slots.append(date)
                self.form.slots.sort()
                self.tableView.reloadSections([Section.availability.rawValue], with: .automatic)
            }
        }
        present(UINavigationController(rootViewController: vc), animated: true)
    }

    private func formattedSlot(_ d: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df.string(from: d)
    }

    // MARK: - Area Selector
    private func presentAreaSelector() {
        let vc = AreaSelectionViewController(selected: Array(form.mentorshipAreas.keys))
        vc.completion = { [weak self] selected in
            guard let self = self else { return }

            // Add new areas
            selected.forEach { if self.form.mentorshipAreas[$0] == nil { self.form.mentorshipAreas[$0] = "" }}

            // Remove unselected
            let removed = Set(self.form.mentorshipAreas.keys).subtracting(selected)
            removed.forEach { self.form.mentorshipAreas.removeValue(forKey: $0) }

            self.tableView.reloadSections([Section.expertise.rawValue], with: .automatic)
        }

        present(UINavigationController(rootViewController: vc), animated: true)
    }

    // MARK: - Price Sheet
    private func presentPriceSelector(for area: String) {
        let ac = UIAlertController(title: "Price for \"\(area)\"",
                                   message: "Choose a price",
                                   preferredStyle: .actionSheet)

        let prices = ["₹ 300/hour","₹ 500/hour","₹ 700/hour","₹ 1k/hour","₹ 1.5k/hour","₹ 2k/hour","Custom..."]

        for p in prices {
            ac.addAction(UIAlertAction(title: p, style: .default) { _ in
                if p == "Custom..." {
                    self.presentCustomPriceInput(for: area)
                } else {
                    self.form.mentorshipAreas[area] = p
                    self.tableView.reloadSections([Section.expertise.rawValue], with: .automatic)
                }
            })
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }

    private func presentCustomPriceInput(for area: String) {
        let ac = UIAlertController(title: "Custom price", message: nil, preferredStyle: .alert)
        ac.addTextField { $0.placeholder = "₹ 250/hour" }
        ac.addAction(UIAlertAction(title: "Done", style: .default) { _ in
            if let text = ac.textFields?.first?.text, !text.isEmpty {
                self.form.mentorshipAreas[area] = text
                self.tableView.reloadSections([Section.expertise.rawValue], with: .automatic)
            }
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }

    // MARK: - Experience Sheet
    private func presentYearsActionSheet() {
        let ac = UIAlertController(title: "Years of Experience", message: nil, preferredStyle: .actionSheet)
        ["<1", "1–3", "3–5", "5+"].forEach { item in
            ac.addAction(UIAlertAction(title: item, style: .default) { _ in
                self.form.years = item
                self.tableView.reloadSections([Section.basicInfo.rawValue], with: .automatic)
            })
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }

    // MARK: - Photo Picker
    private func presentPhotoPicker() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    // MARK: - Submit
    @objc private func didTapSubmit() {
        guard let name = form.fullName, !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            showAlert(title: "Missing name", message: "Please enter your full name.")
            return
        }
        guard !form.mentorshipAreas.isEmpty else {
            showAlert(title: "No mentorship area", message: "Select at least one area.")
            return
        }
        guard form.mentorshipAreas.values.allSatisfy({ !$0.isEmpty }) else {
            showAlert(title: "Price missing", message: "Set a price for each area.")
            return
        }

        // on success show alert then push MentorPanelViewController
        showAlert(title: "Submitted", message: "Your profile has been submitted.") {
            DispatchQueue.main.async {
                if let nav = self.navigationController {
                    let mentorPanel = MentorPanelViewController()
                    mentorPanel.hidesBottomBarWhenPushed = true
                    nav.pushViewController(mentorPanel, animated: true)
                } else {
                    // fallback: present modally wrapped in a nav controller
                    let mentorPanel = MentorPanelViewController()
                    let nav = UINavigationController(rootViewController: mentorPanel)
                    self.present(nav, animated: true, completion: nil)
                }
            }
        }
    }

    private func showAlert(title: String,
                           message: String,
                           completion: (() -> Void)? = nil) {

        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default) { _ in completion?() })
        present(ac, animated: true)
    }
}

// MARK: - PHPicker Delegate
extension BecomeMentorViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController,
                didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let item = results.first else { return }

        if item.itemProvider.canLoadObject(ofClass: UIImage.self) {
            item.itemProvider.loadObject(ofClass: UIImage.self) { obj, _ in
                DispatchQueue.main.async {
                    if let img = obj as? UIImage {
                        self.form.avatarImage = img
                        self.tableView.reloadSections([Section.attach.rawValue], with: .automatic)
                    }
                }
            }
        }
    }
}

// MARK: - AreaSelectionViewController
final class AreaSelectionViewController: UITableViewController {

    private let allAreas = [
        "Acting", "Communication", "Directing", "Dubbing",
        "Voice over", "Editing", "Casting", "Writing", "Others"
    ]

    private var selected: Set<String>
    var completion: (([String]) -> Void)?

    init(selected: [String]) {
        self.selected = Set(selected)
        super.init(style: .insetGrouped)
        title = "Mentorship Area"
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        navigationItem.leftBarButtonItem =
            UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        allAreas.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let area = allAreas[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        var config = cell.defaultContentConfiguration()
        config.text = area
        cell.contentConfiguration = config

        cell.accessoryType = selected.contains(area) ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {

        let area = allAreas[indexPath.row]

        if selected.contains(area) {
            selected.remove(area)
        } else {
            selected.insert(area)
        }

        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    @objc private func doneTapped() {
        completion?(Array(selected))
        dismiss(animated: true)
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
}

// MARK: - AddSlotViewController
final class AddSlotViewController: UIViewController {

    var completion: ((Date) -> Void)?

    private let datePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .date
        if #available(iOS 13.4, *) {
            dp.preferredDatePickerStyle = .inline
        }
        dp.translatesAutoresizingMaskIntoConstraints = false
        return dp
    }()

    private let timePicker: UIDatePicker = {
        let tp = UIDatePicker()
        tp.datePickerMode = .time
        tp.translatesAutoresizingMaskIntoConstraints = false
        return tp
    }()

    private lazy var addButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Add Slot", for: .normal)
        b.backgroundColor = UIColor(red: 0x43/255, green: 0x16/255, blue: 0x31/255, alpha: 1)
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 10
        b.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        return b
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        title = "Add Availability"
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))

        view.addSubview(datePicker)
        view.addSubview(timePicker)
        view.addSubview(addButton)

        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            timePicker.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 16),
            timePicker.leadingAnchor.constraint(equalTo: datePicker.leadingAnchor),
            timePicker.trailingAnchor.constraint(equalTo: datePicker.trailingAnchor),

            addButton.topAnchor.constraint(equalTo: timePicker.bottomAnchor, constant: 24),
            addButton.leadingAnchor.constraint(equalTo: datePicker.leadingAnchor),
            addButton.trailingAnchor.constraint(equalTo: datePicker.trailingAnchor),
            addButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    @objc private func addTapped() {
        var comps = DateComponents()

        let date = datePicker.date
        let time = timePicker.date

        let c = Calendar.current
        comps.year = c.component(.year, from: date)
        comps.month = c.component(.month, from: date)
        comps.day = c.component(.day, from: date)
        comps.hour = c.component(.hour, from: time)
        comps.minute = c.component(.minute, from: time)

        let finalDate = Calendar.current.date(from: comps) ?? date
        completion?(finalDate)
        dismiss(animated: true)
    }

    @objc private func cancel() {
        dismiss(animated: true)
    }
}

// MARK: - TextFieldCell
final class TextFieldCell: UITableViewCell, UITextFieldDelegate {

    private let textField: UITextField = {
        let tf = UITextField()
        tf.clearButtonMode = .whileEditing
        tf.font = UIFont.preferredFont(forTextStyle: .body)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private var changeHandler: ((String?) -> Void)?

    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(textField)

        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            textField.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor, constant: 6),
            textField.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor, constant: -6)
        ])

        textField.delegate = self
        selectionStyle = .none
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(placeholder: String,
                   text: String?,
                   onChange: @escaping (String?) -> Void) {

        textField.placeholder = placeholder
        textField.text = text
        changeHandler = onChange
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        changeHandler?(textField.text)
    }
}

// MARK: - TextViewCell
final class TextViewCell: UITableViewCell, UITextViewDelegate {

    private let textView = UITextView()
    private var changeHandler: ((String?) -> Void)?

    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.isScrollEnabled = false
        textView.layer.cornerRadius = 8
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        textView.backgroundColor = .secondarySystemBackground

        textView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textView)

        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            textView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            textView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])

        textView.delegate = self
        selectionStyle = .none
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(text: String?,
                   placeholder: String,
                   onChange: @escaping (String?) -> Void) {

        changeHandler = onChange

        if let t = text, !t.isEmpty {
            textView.text = t
            textView.textColor = .label
        } else {
            textView.text = placeholder
            textView.textColor = .secondaryLabel
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .secondaryLabel {
            textView.text = ""
            textView.textColor = .label
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        changeHandler?(textView.text)
    }
}

// MARK: - PickerCell
final class PickerCell: UITableViewCell {

    private var datePicker: UIDatePicker?
    private var handler: ((Date) -> Void)?

    func configureAsDatePicker(mode: UIDatePicker.Mode,
                               date: Date,
                               onChange: @escaping (Date) -> Void) {

        handler = onChange

        if datePicker == nil {
            let dp = UIDatePicker()
            dp.datePickerMode = mode

            if #available(iOS 13.4, *) {
                dp.preferredDatePickerStyle = .inline
            }

            dp.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(dp)

            NSLayoutConstraint.activate([
                dp.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
                dp.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
                dp.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
                dp.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
            ])

            dp.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
            datePicker = dp
        }

        datePicker?.date = date
    }

    @objc private func valueChanged(_ dp: UIDatePicker) {
        handler?(dp.date)
    }
}

// MARK: - AvatarCell
final class AvatarCell: UITableViewCell {

    private var tapHandler: (() -> Void)?

    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {

        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        if let img = imageView {
            img.translatesAutoresizingMaskIntoConstraints = false
            img.contentMode = .scaleAspectFill
            img.layer.cornerRadius = 20
            img.clipsToBounds = true

            NSLayoutConstraint.activate([
                img.widthAnchor.constraint(equalToConstant: 40),
                img.heightAnchor.constraint(equalToConstant: 40)
            ])
        }

        textLabel?.font = .preferredFont(forTextStyle: .body)
        accessoryType = .disclosureIndicator
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(image: UIImage?,
                   onTap: @escaping () -> Void) {

        tapHandler = onTap

        if let img = image {
            imageView?.image = img
            textLabel?.text = "Change photo"
        } else {
            imageView?.image = UIImage(systemName: "person.crop.circle.fill")
            imageView?.tintColor = .systemGray3
            textLabel?.text = "Upload profile photo"
            textLabel?.textColor = .secondaryLabel
        }
    }
}
