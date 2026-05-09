//
//  Activity.swift
//  FPE
//
import Foundation

struct Activity: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var isComplete: Bool
    var creationDate: Date = Date()
}
