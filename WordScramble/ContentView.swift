//
//  ContentView.swift
//  WordScramble
//
//  Created by Igor Shcherba on 27/04/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""

    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }

                Section {
                    ForEach(usedWords, id: \.self) { word in

                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .toolbar {
                Button("Restart game") {
                    startGame()
                }
            }
            .navigationTitle($rootWord)
            .onSubmit(addWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {} message: {
                Text(errorMessage)
            }
        }
    }

    func addWord() {
        let word = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        guard word.count > 0 else { return }

        guard isOriginal(word: word) else {
            showError(title: "Word used alread", message: "Be more original!")
            return
        }

        guard isReal(word: word) else {
            showError(title: "Not a real word", message: "You can't just make them up, you know!")
            return
        }

        guard isPossible(word: word) else {
            showError(title: "Word not possible", message: "You can't spell this word from \(rootWord)")
            return
        }

        withAnimation {
            usedWords.insert(word, at: 0)
        }

        newWord = ""
    }

    func startGame() {
        errorTitle = ""
        errorMessage = ""
        usedWords.removeAll()
        newWord = ""

        if let startWordsUrl = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsUrl) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"

                return
            }
        }

        fatalError("Couldn't load start.txt from bundle")
    }

    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }

    func isPossible(word: String) -> Bool {
        var temp = rootWord
        for letter in word {
            if let pos = temp.firstIndex(of: letter) {
                temp.remove(at: pos)
            } else {
                return false
            }
        }

        return true
    }

    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)

        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }

    func showError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

#Preview {
    ContentView()
}
