import UIKit

class CreateAcronymTableViewController: UITableViewController {
  // MARK: - IBOutlets
  @IBOutlet weak var acronymShortTextField: UITextField!
  @IBOutlet weak var acronymLongTextField: UITextField!
  @IBOutlet weak var userLabel: UILabel!
  
  // MARK: - Properties
  var selectedUser: User?
  var acronym: Acronym?
  
  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    acronymShortTextField.becomeFirstResponder()
    if let acronym = acronym {
      acronymShortTextField.text = acronym.short
      acronymLongTextField.text = acronym.long
      userLabel.text = selectedUser?.name
      navigationItem.title = "Edit Acronym"
    } else {
      populateUsers()
    }
  }
  
  func populateUsers() {
    let usersRequest = ResourceRequest<User>(resourcePath: "users")
    
    usersRequest.getAll { [weak self] result in
      switch result {
      case .failure:
        let message = "There was an error getting the users"
        ErrorPresenter.showError(message: message, on: self) { _ in
          self?.navigationController?.popViewController(animated: true)
        }
      case .success(let users):
        DispatchQueue.main.async { [weak self] in
          self?.userLabel.text = users[0].name
        }
        self?.selectedUser = users[0]
      }
    }
  }
  
  // MARK: - Navigation
  @IBSegueAction func makeSelectUserViewController(_ coder: NSCoder) -> SelectUserTableViewController? {
    guard let user = selectedUser else {
      return nil
    }
    return SelectUserTableViewController(coder: coder, selectedUser: user)
  }
  
  
  // MARK: - IBActions
  @IBAction func cancel(_ sender: UIBarButtonItem) {
    navigationController?.popViewController(animated: true)
  }
  
  @IBAction func save(_ sender: UIBarButtonItem) {
    guard let shortText = acronymShortTextField.text, !shortText.isEmpty else {
      ErrorPresenter.showError(message: "You must specify an acronym!", on: self)
      return
    }
    guard let longText = acronymLongTextField.text, !longText.isEmpty else {
      ErrorPresenter.showError(message: "You must specify a meaning!", on: self)
      return
    }
    guard let userID = selectedUser?.id else {
      let message = "You must have a user to create an acronym!"
      ErrorPresenter.showError(message: message, on: self)
      return
    }
    
    let acronym = Acronym(short: shortText, long: longText, userID: userID)
    let acronymSaveData = acronym.toCreateData()
    
    if self.acronym != nil {
      // update code goes here
      guard let existingID = self.acronym?.id else {
        let message = "There was an error updating the acronym"
        ErrorPresenter.showError(message: message, on: self)
        return
      }
      AcronymRequest(acronymID: existingID)
        .update(with: acronymSaveData) { result in
          switch result {
          case .failure:
            let message = "There was a problem saving the acronym"
            ErrorPresenter.showError(message: message, on: self)
          case .success(let updatedAcronym):
            self.acronym = updatedAcronym
            DispatchQueue.main.async { [weak self] in
              self?.performSegue(
                withIdentifier: "UpdateAcronymDetails",
                sender: nil)
            }
          }
        }
    } else {
      ResourceRequest<Acronym>(resourcePath: "acronyms")
        .save(acronymSaveData) { [weak self] result in
          switch result {
          case .failure:
            let message = "There was a problem saving the acronym"
            ErrorPresenter.showError(message: message, on: self)
          case .success:
            DispatchQueue.main.async { [weak self] in
              self?.navigationController?
                .popViewController(animated: true)
            }
          }
        }
    }
  }
  
  @IBAction func updateSelectedUser(_ segue: UIStoryboardSegue) {
    guard let controller = segue.source as? SelectUserTableViewController else {
      return
    }
    selectedUser = controller.selectedUser
    userLabel.text = selectedUser?.name
  }
}
