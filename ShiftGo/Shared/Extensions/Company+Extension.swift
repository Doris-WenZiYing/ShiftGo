//
//  Company+Extension.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/9/18.
//

import Foundation

extension Company {
    // MARK: - Static Factory Method
    static func from(data: [String: Any], id: String) throws -> Company {
        guard let name = data["name"] as? String,
              let ownerId = data["owner_id"] as? String,
              let inviteCode = data["invite_code"] as? String else {
            throw FirebaseError.invalidCompanyData
        }

        let maxEmployees = data["max_employees"] as? Int ?? 50
        let timezone = data["timezone"] as? String ?? "Asia/Taipei"
        let industry = data["industry"] as? String
        let address = data["address"] as? String
        let logoURL = data["logo_url"] as? String

        // Handle timestamps
        let createdAt = data["created_at"] as? Timestamp ?? Timestamp()
        let updatedAt = data["updated_at"] as? Timestamp ?? Timestamp()

        return Company(
            id: id,
            name: name,
            ownerId: ownerId,
            inviteCode: inviteCode,
            maxEmployees: maxEmployees,
            timezone: timezone,
            industry: industry,
            address: address,
            logoURL: logoURL,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    // MARK: - Dictionary Conversion
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "name": name,
            "owner_id": ownerId,
            "invite_code": inviteCode,
            "max_employees": maxEmployees,
            "timezone": timezone,
            "created_at": createdAt,
            "updated_at": updatedAt
        ]

        if let industry = industry {
            dict["industry"] = industry
        }

        if let address = address {
            dict["address"] = address
        }

        if let logoURL = logoURL {
            dict["logo_url"] = logoURL
        }

        return dict
    }

    // MARK: - Validation
    var isValid: Bool {
        return !name.isEmpty &&
               !ownerId.isEmpty &&
               !inviteCode.isEmpty &&
               maxEmployees > 0
    }

    var canAddMoreEmployees: Bool {
        // This would need to be checked against actual employee count
        // For now, assume it's always possible unless at max
        return maxEmployees > 0
    }

    // MARK: - Helper Methods
    func generateNewInviteCode() -> Company {
        let newCode = String.randomAlphanumeric(length: 6).uppercased()
        return Company(
            id: id,
            name: name,
            ownerId: ownerId,
            inviteCode: newCode,
            maxEmployees: maxEmployees,
            timezone: timezone,
            industry: industry,
            address: address,
            logoURL: logoURL,
            createdAt: createdAt,
            updatedAt: Timestamp()
        )
    }

    func updateInfo(name: String? = nil, industry: String? = nil,
                   address: String? = nil, timezone: String? = nil) -> Company {
        return Company(
            id: id,
            name: name ?? self.name,
            ownerId: ownerId,
            inviteCode: inviteCode,
            maxEmployees: maxEmployees,
            timezone: timezone ?? self.timezone,
            industry: industry ?? self.industry,
            address: address ?? self.address,
            logoURL: logoURL,
            createdAt: createdAt,
            updatedAt: Timestamp()
        )
    }
}

// MARK: - String Extension for Random Generation
private extension String {
    static func randomAlphanumeric(length: Int) -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
}
