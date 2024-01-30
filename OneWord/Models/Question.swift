//
//  Question.swift
//  OneWord
//
//  Created by Cory Tripathy on 1/25/24.
//

import CloudKit

struct Question {
    init(atIndex index: Int) {
        self.description = Self.all[index]
    }
    let description: String
    static let all: [String] = [
        "What's the secret to a happy life?",
        "In my next life, I want to be reincarnated as _______.",
        "The latest fashion trend involves wearing _______ as an accessory.",
        "What's the best way to impress your grandparents?",
        "If animals could talk, which one would give the best advice?",
        "The key to a successful friendship is built on a foundation of _______.",
        "In a parallel universe, people communicate through _______.",
        "What's the newest dance move that's taking the world by storm?",
        "The government has announced a tax break for anyone who can successfully _______.",
        "My autobiography will be titled 'The Chronicles of _______'.",
        "The secret ingredient in grandma's famous cookies is _______.",
        "What's the most unlikely superhero power you can think of?",
        "If I were a genie, my three wishes would be _______.",
        "What's the best way to start a party?",
        "The latest fitness trend involves a workout routine with _______.",
        "If I could have dinner with any historical figure, it would be _______.",
        "The world would be a better place if everyone had a pet _______.",
        "What's the key to a successful road trip?",
        "The next blockbuster movie will feature _______ as the main character.",
        "The best pickup line involves mentioning _______.",
        "If I could have any superpower, it would be the ability to control _______.",
        "In the future, we'll communicate exclusively through _______.",
        "The best way to solve a problem is by using _______.",
        "What's the most unexpected use for a pineapple?",
        "My secret talent is being able to impersonate _______.",
        "The recipe for a perfect day includes a dash of _______.",
        "If I were a wizard, my specialty would be casting spells involving _______.",
        "The secret to a successful comedy show is a lineup of hilarious _______.",
        "The next internet sensation will be based on _______.",
        "What's the best way to escape a boring conversation?",
        "If I were a time traveler, I would visit the era of _______.",
        "What's the most underrated vegetable?",
        "In a game of charades, I'd be a pro at acting out _______.",
        "The solution to world peace is a global treaty on _______.",
        "What's the most unexpected thing you could find in a treasure chest?",
        "The key to a happy marriage is a shared love for _______.",
        "If I could have any mythical creature as a pet, it would be a _______.",
        "The theme for my dream vacation is _______.",
        "The best way to break the ice at a party is by telling a joke about _______.",
        "What's the most unusual flavor for an ice cream?",
        "If I were a detective, my signature catchphrase would be _______.",
        "The newest reality show is a competition for the best _______.",
        "What's the most unexpected use for a rubber duck?",
        "In an alternate universe, the currency is based on _______.",
        "My secret talent is juggling _______.",
        "The best way to make friends at a dog park is by bringing _______.",
        "If I were a wizard, my wand would be made of _______.",
        "The secret to a successful DIY project is plenty of _______.",
        "The next big viral meme will feature _______.",
        "If I were a professional athlete, my sport would be _______."
    ]
}
