//
//  Game.swift
//  ApplePie
//
//  Created by Takayuki Yamaguchi on 2020-12-09.
//

import Foundation

/*
 A Game object that stores
  - word: current game's answer
  - incorrectMovesRemaining: how many times you can mistake
  - guessedLetters: array of letters user has guessed
  - formattedWord: return current game's answer. But if the user haven't guess the letter, make it blank, like ___a___
  
 */
struct Game {
    var word: String
    var incorrectMovesRemaining: Int
    var guessedLetters: [Character]
  
    var formattedWord: String {
        var guessedWord = ""
        for letter in word {
            if guessedLetters.contains(letter) {
                guessedWord += "\(letter)"
            } else {
                guessedWord += "_"
            }
        }
        return guessedWord
    }

  /*
   Store the letter user has guessed,
   if it's not in the answer, decrement "incorrectMovesRemaining "
   */
    mutating func playerGuessed(letter: Character) {
      guessedLetters.append(letter)
      if !word.contains(letter) {
        incorrectMovesRemaining -= 1
      }
    }
}
