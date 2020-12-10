//
//  ViewController.swift
//  ApplePie
//
//  Created by Takayuki Yamaguchi on 2020-12-08.
//

import UIKit

class ViewController: UIViewController {
  
  
  
  
  /*
   Instance variables related to layout  -------------------------------
   */
  
  
  /*
   Set the tree image
   */
  let treeImageView: UIImageView = {
    let tv =  UIImageView(image: UIImage(named: "Tree 7"))
    tv.translatesAutoresizingMaskIntoConstraints = false
    tv.contentMode = .scaleAspectFit
    tv.backgroundColor = .green
    return tv
  }()
  

  
  /*
   Set the keyboard stack views
   */
  
  //Set data of key(str) sets
  let strSetTop    : [String] = ["Q","W","E","R","T","Y","U","I","O","P"]
  let strSetCenter : [String] = ["A","S","D","F","G","H","J","K","L"]
  let strSetBottom : [String] = ["Z","X","C","V","B","N","M"]
  
  //Set 3 rows(lins) as a stack view
  lazy var RowStackViewTop    = createRowStackView(strSet: strSetTop)
  lazy var RowStackViewCenter = createRowStackView(strSet: strSetCenter)
  lazy var RowStackViewBottom = createRowStackView(strSet: strSetBottom)
  
  //Unify all botton and return it when it's called.
  //This computed variable is necessary whne you want to set constrains or change property of all bottons.
  var AllBottonViews: [UIView] {
    return(
      RowStackViewTop.arrangedSubviews    +
      RowStackViewCenter.arrangedSubviews +
      RowStackViewBottom.arrangedSubviews
    )
  }
  
  //Set main keyboard stack view with using 3 rows(lines) stack views.
  lazy var keyboardStackView: UIStackView = {
    var st = UIStackView()
    st = UIStackView(arrangedSubviews: [RowStackViewTop,RowStackViewCenter,RowStackViewBottom])
    st.translatesAutoresizingMaskIntoConstraints = false
    st.axis = .vertical
    st.alignment = .center
    st.backgroundColor = .orange

    st.isLayoutMarginsRelativeArrangement = true
    st.distribution = .fillEqually
    st.spacing = 16
    st.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
    return st
  }()
  
  
  
  
  /*
    Set label stack views
   */
  //Set first label
  let correctWordLabel: UILabel =  {
    let lb = UILabel()
    lb.translatesAutoresizingMaskIntoConstraints = false
    lb.text = ""
    lb.backgroundColor = .red
    return lb
  }()
  
  //Set second label
  let scoreLabel: UILabel = {
    let lb = UILabel()
    lb.translatesAutoresizingMaskIntoConstraints = false
    lb.text = "Wins: , Losses: "
    lb.backgroundColor = .red
    return lb
  }()
  
  //Set label Statck view with using 2 labes
  lazy var labelStackView : UIStackView = {
    let sv = UIStackView(arrangedSubviews: [correctWordLabel, scoreLabel])
    sv.translatesAutoresizingMaskIntoConstraints = false
    sv.axis = .vertical
    sv.alignment = .center
    sv.backgroundColor = .orange

    sv.isLayoutMarginsRelativeArrangement = true
    sv.distribution = .fillEqually
    sv.spacing = 16
    sv.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
    return sv
  }()
  
  
  
  
  
  /*
   Instance variables ralated to logic -------------------------------
   */
  
  //Answer list used for each game.
  var listOfWords = ["buccaneer", "swift", "glorious", "incandescent", "bug", "program"]
  //How many times you can mistake
  let incorrectMovesAllowed = 7

  //The number of ficotories and defeafs that user did.
  // newRound means that new game is executed each time the value changes.
  var totalWins = 0 {
      didSet {
          newRound()
      }
  }
  var totalLosses = 0 {
      didSet {
          newRound()
      }
  }

  // Create game as object.
  // Inside the game, we store answer, how many times user can mistake, what letters you has guessed.
  var currentGame: Game!

  
  
  
  
  
  
  /*
   Methods   -------------------------------
   */
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    setupLayout()
    newRound()
  }

  
  /*
   Set up all layout using one main stack view.
   Stack view includes
     - tree image
     - key board
     - lebel
      
   */
  func setupLayout(){
    /*
     Set mainStack view
     */
    let mainStackView = UIStackView(arrangedSubviews: [treeImageView, keyboardStackView, labelStackView])
    mainStackView.translatesAutoresizingMaskIntoConstraints = false
    mainStackView.axis = .vertical
    mainStackView.alignment = .center

    mainStackView.isLayoutMarginsRelativeArrangement = true
    mainStackView.distribution = .equalSpacing
    mainStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
    view.addSubview(mainStackView)
    
    NSLayoutConstraint.activate([
      mainStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      mainStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      mainStackView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1.0),
    ])
    
    
    /*
     Set each subviews' constrains
     */
    
    // Tree
    NSLayoutConstraint.activate([
      treeImageView.heightAnchor.constraint(equalTo: mainStackView.heightAnchor, multiplier: 0.5)
    ])

    // Keyboard
    NSLayoutConstraint.activate([
      keyboardStackView.heightAnchor.constraint(equalTo: mainStackView.heightAnchor, multiplier: 0.3),
    ])

    // Each bt in keyboard
    for bt in AllBottonViews{
      NSLayoutConstraint.activate([
        bt.widthAnchor.constraint(equalToConstant: 48),
        bt.heightAnchor.constraint(equalToConstant: 48)
      ])
    }
    
    //Label
    NSLayoutConstraint.activate([
      labelStackView.heightAnchor.constraint(equalTo: mainStackView.heightAnchor, multiplier: 0.1)
    ])
    
  }
  
  
  /*
   Core function.
   Create a new Game object (as far as answer list is not empty), and update UI
   so that user can play another new game.
   
   If there is no answer words left, disable bottons.
   */
  func newRound() {
    
      if !listOfWords.isEmpty {
          let newWord = listOfWords.removeFirst()
          currentGame = Game(word: newWord, incorrectMovesRemaining: incorrectMovesAllowed, guessedLetters: [])
          enableLetterButtons(true)
          updateUI()
      } else {
          enableLetterButtons(false)
      }
  }

  
  /*
   By passing Boolean, We can enable(disable) button, so that the user can (can't) play a game.
   */
  func enableLetterButtons(_ enable: Bool) {
    
    for bt in AllBottonViews{
        if let b = bt as? UIButton{
          b.isEnabled = enable
          b.setTitleColor(enable ? .cyan : .gray, for: .normal)
        }
    }
  }

  /*
   Validate if current game is over or not.
   If the user did more than allowed incrrect answer -> lose,
   If the answer is totally same as user's guess -> win,
   Otherwise, updateUI == change label ____
   */
  func updateGameState() {
    if currentGame.incorrectMovesRemaining == 0 {
      totalLosses += 1
    } else if currentGame.word == currentGame.formattedWord {
      totalWins += 1
    } else {
      updateUI()
    }
  }

  /*
   Update letters _____, tree images, and the number of vitories and defeats user did.
   This method is called,
    - first time a new game is created
    - When user presses a button (and no win nor lose occures)
   */
  func updateUI() {
      var letters = [String]()
      for letter in currentGame.formattedWord {
          letters.append(String(letter))
      }
      let wordWithSpacing = letters.joined(separator: "")
    
      correctWordLabel.text = wordWithSpacing
      scoreLabel.text = "Wins: \(totalWins), Losses:\(totalLosses)"
      treeImageView.image = UIImage(named: "Tree \(currentGame.incorrectMovesRemaining)")
  }
  
  
  
  /*
   Create a row(line) stack view using string sets.
   ex)  ["a","b","c"] : Input -> return Stack view that pocess  [ a:UIBotton , b:UIBotton ,c:UIBotton ]
   */
  func createRowStackView(strSet :[String]) -> UIStackView{
    var bts:[UIView] = []
    
    //Set button and add as array
    for str in strSet{
      let bt = UIButton()
      bt.translatesAutoresizingMaskIntoConstraints = false
      bt.setTitle(str, for: .normal)
      bt.setTitleColor(.cyan, for: .normal)
      bt.setTitleColor(.blue, for: .highlighted)
      bt.addTarget(self, action: #selector(letterButtonPressed), for: .touchUpInside)
      bt.backgroundColor  = .blue
      bts += [bt]
    }
    
    //Set stack view and add property and margin
    let st = UIStackView(arrangedSubviews:bts)
    st.translatesAutoresizingMaskIntoConstraints = false
    st.axis = .horizontal
    st.alignment = .center
    st.backgroundColor = .red
    st.distribution = .fillEqually
    
    st.isLayoutMarginsRelativeArrangement = true
    st.spacing = 16
    st.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
    
    return st
  }
  

  /*
   Called when each botton is pressed.
   The pressed botton is no longer enable and changes its color until nextround.
   After pressed, the current Game status is updated
   and in addition, the Total Game status (win, lose) is also updated
   */
  @objc func letterButtonPressed(sender: UIButton!) {
    print(sender.title(for: .normal)!)
    sender.isEnabled = false
    sender.setTitleColor(.gray, for: .normal)
    let letterString = sender.title(for: .normal)!
    let letter = Character(letterString.lowercased())
    currentGame.playerGuessed(letter: letter)
    updateGameState()
  }
  
  
  

}
//
//
//lazy var keyboardStackView: UIStackView = {
//
//  let strSets : [[String]] = [strSet1,strSet2,strSet3]
//
//  var keyboardStackView = UIStackView()
//
//  var keyboardSubViews:[UIStackView] = []
//  for strSet in strSets{
//
//    var LineSubViews:[UIView] = []
//    for str in strSet{
//      let bt = UIButton()
////        keyButton.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
//      bt.translatesAutoresizingMaskIntoConstraints = false
//      bt.setTitle(str, for: .normal)
//      bt.setTitleColor(.cyan, for: .normal)
//      bt.setTitleColor(.blue, for: .highlighted)
//      bt.addTarget(self, action: #selector(letterButtonPressed), for: .touchUpInside)
//      bt.backgroundColor  = .blue
//      LineSubViews += [bt]
//
//    }
//
//    let LineStackView = UIStackView(arrangedSubviews: LineSubViews)
//    LineStackView.translatesAutoresizingMaskIntoConstraints = false
//    LineStackView.axis = .horizontal
//    LineStackView.alignment = .center
//    LineStackView.backgroundColor = .red
//    LineStackView.distribution = .fillEqually
//
//    LineStackView.isLayoutMarginsRelativeArrangement = true
//    LineStackView.spacing = 16
//    LineStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
//
//    keyboardSubViews += [LineStackView]
//  }
//
//  keyboardStackView = UIStackView(arrangedSubviews: keyboardSubViews)
//  keyboardStackView.translatesAutoresizingMaskIntoConstraints = false
//  keyboardStackView.axis = .vertical
//  keyboardStackView.alignment = .center
//  keyboardStackView.backgroundColor = .orange
//
//  keyboardStackView.isLayoutMarginsRelativeArrangement = true
//  keyboardStackView.distribution = .fillEqually
//  keyboardStackView.spacing = 16
//  keyboardStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
//  return keyboardStackView
//
//}()
