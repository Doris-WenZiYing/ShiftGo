//
//  Company.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/9/18.
//

import Foundation
import SwiftUI
import FirebaseFirestore

// MARK: - Company Model
struct Company: Identifiable {
    var id: String = ""
    let name: String
    let ownerId: String
    let inviteCode: String
    let maxEmployees: Int
    let timezone: String
    let industry: String?
    let address: String?
    let logoURL: String?
    let createdAt: Timestamp
    let updatedAt: Timestamp

    init(id: String = "", name: String, ownerId: String, inviteCode: String,
         maxEmployees: Int = 50, timezone: String = "Asia/Taipei",
         industry: String? = nil, address: String? = nil, logoURL: String? = nil,
         createdAt: Timestamp = Timestamp(), updatedAt: Timestamp = Timestamp()) {
        self.id = id
        self.name = name
        self.ownerId = ownerId
        self.inviteCode = inviteCode
        self.maxEmployees = maxEmployees
        self.timezone = timezone
        self.industry = industry
        self.address = address
        self.logoURL = logoURL
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    static func demoCompany() -> Company {
        return Company(
            id: "demo_company",
            name: "demo_company_name".localized,
            ownerId: "demo_owner",
            inviteCode: "DEMO01"
        )
    }

    var displayTimezone: String {
        let formatter = TimeZone(identifier: timezone)?.localizedName(for: .standard, locale: .current) ?? timezone
        return formatter
    }
}

// MARK: - Company Codable Extension
extension Company: Codable {
    enum CodingKeys: String, CodingKey {
        case id, name, industry, address
        case ownerId = "owner_id"
        case inviteCode = "invite_code"
        case maxEmployees = "max_employees"
        case timezone
        case logoURL = "logo_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        name = try container.decode(String.self, forKey: .name)
        ownerId = try container.decode(String.self, forKey: .ownerId)
        inviteCode = try container.decode(String.self, forKey: .inviteCode)
        maxEmployees = try container.decodeIfPresent(Int.self, forKey: .maxEmployees) ?? 50
        timezone = try container.decodeIfPresent(String.self, forKey: .timezone) ?? "Asia/Taipei"
        industry = try container.decodeIfPresent(String.self, forKey: .industry)
        address = try container.decodeIfPresent(String.self, forKey: .address)
        logoURL = try container.decodeIfPresent(String.self, forKey: .logoURL)
        createdAt = try container.decodeIfPresent(Timestamp.self, forKey: .createdAt) ?? Timestamp()
        updatedAt = try container.decodeIfPresent(Timestamp.self, forKey: .updatedAt) ?? Timestamp()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(ownerId, forKey: .ownerId)
        try container.encode(inviteCode, forKey: .inviteCode)
        try container.encode(maxEmployees, forKey: .maxEmployees)
        try container.encode(timezone, forKey: .timezone)
        try container.encodeIfPresent(industry, forKey: .industry)
        try container.encodeIfPresent(address, forKey: .address)
        try container.encodeIfPresent(logoURL, forKey: .logoURL)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
}
